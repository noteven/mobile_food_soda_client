# Notes

These notes are provided in satisfaction of the requirement for a documented though process as per the
[PROBLEM_STATEMENT.md](PROBLEM_STATEMENT.md) file.

## Project definition

Initially the only idea that came to mind was front-end oriented projects such as data visualization or querying, but both of these functionalities were already well supported - San Franciscos' Mobile Food Facility Permit [SODA API](https://data.sfgov.org/resource/rqzj-sfat.json), hence forth the API, supports robust querying and theres a somewhat functional Maps style visualization available. As happens when searching for a problem to a solution I was trying to come up with a problem that would allow me to utilize [Broadway](https://github.com/dashbitco/broadway), [libCluster](https://github.com/bitwalker/libcluster), [Ecto](https://github.com/elixir-ecto/ecto), or Erlang Term Storage ([ETS](https://www.erlang.org/doc/man/ets.html)). Thinking about it I decided that no matter what I decided to implement, I would need a client to the API, so I might as well start from there.

In all honesty I don't expect to be able to actually develop a project using the client, but if I did, I would probably try implementing something that simply takes messages on a Broadway pipeline and uses the client to query the information from the SODA API. Hopefully going that route I'd get to look into using Kubernetes and libCluster for distributed Elixir, which in turn would mean looking into distributed tracing, Grafana and possibly Terraform. This would provide a fertile bed for exploring new technologies/skills, but for which a non-negligible amount of time would be required. The library itself could also be extended to support more HTTP Client and parsers as necessary, but I decided to limit it to JSON and CSV (for tests).

## Project Set-up

First step is setting up project, that means setting up basic developer code-quality tooling (credo, dialyzer), git files (.gitignore), and Github Workflow for continuous integration and continuous delivery (CI/CD). As this project is implementing a library, the CD portion is not applicable (no formal releases). Furthermore a permissive software license is chosen (MIT) and a .editorconfig is provided for completion of basic project layout.

During setting-up CI/CD it is necessary to pay attention to caching for not only dependencies but Dialyzer to bring down the runtime. Managing build/test times is important as Workflow is billed/tiered by minutes[^1], and in developer workflow fast turnaround time is important for developer experience.

This work culminated in commit 64984265274136e2344dcc360d86864e2b8ef8e3 which set-up the main branch for use in Github Flow style development (feature/hotfix branching). Feature branches may now be created, merged in and tested automatically.

[^1]: https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions

## First features

Development continues by writing out some basic tests to help guide software architecture/design decisions by looking at it from an end-user (developer) ergonomics point of view. Further along the process I expect tests to document use-cases, edge-cases and fuzz the system input/output; this should help document behaviour, reveal abnormal behaviour and provide a framework for preventing regressions/bugs.

The first step is the basic behaviour of hitting the San Franciscos' [Mobile Food Facility Permit dataset](https://data.sfgov.org/resource/rqzj-sfat.json) SODA API,
henceforth the end-point, and retrieving the results. Looking at the Mobile Food Permits API and it's documentation there are a couple of things I noticed. First is that theres is data for multiple location systems provided (`(longitud,latitude)` for WGS84, `x` and `y` for CA State Plane III and block-lot for parcel registrar). Furthermore, the field `noisent` exists in the API documentation but is not sent in the API calls themselves, `cnn` field I am unsure what it is for, and `prior_permit` is always zero (0) or one (1) so it would seem that it is being used as a boolean field indicating whether a facility has a prior permit and not to represent how many prior permits a facility has. There are also a few duplicate fields, such as `longitude` and `latitude` being offered as seperate coordinates and as a single coordinate pair, same goes for `block` and `lot`, the URL for the `schedule` field never seems to actually load anything and while `expirationdate` and `approved` are floating timestamps (ISO 8601 `2016-03-15T00:00:00.000`) the `received` field is simply a string in `yyyymmdd` format. The API docs also define `status` as being `APPROVED` or `REQUESTED` but the API also returns `EXPIRED` and `SUSPEND`. Finally, the `dayshours` field is generally blank, and the scheduling data is more richely represented in the Mobile Food Schedule dataset should it be necessary. Given these considerations the following data is omitted: `noisent`, `x`, `y`, `cnn`, `dayshours` and `schedule`.

While looking into the Mobile Food Facility Permit dataset I also found the [Mobile Food Schedule dataset](https://data.sfgov.org/resource/jjew-r69b.json) which appears to offer the working hours for mobile food facilities. It would be useful to combine the two into the client such that it can fetch properties of mobile food facilities from both datasets opaquely. It is possible to use `locationid` to fetch schedule from the Mobile Food Schedule dataset. Fields of interest are `start24`, `end24`, `locationdesc`, `optionaltext`, and `dayorder` (or `dayofweekstr` if string representation preferred). The `locationdesc` differs from the Mobile Food Facility Permit dataset as it contains details about the set-up location (which may not be the same as permit location) and time. `optionaltext` seems to be similar if not the same to `fooditems` from the Mobile Food Facility Permit dataset.

Once a basic structure for the resulting data is laid out, I set up a test to simulate using the client to fetch results, which in turn means utilizing a test double for the SODA API to prevent un-deterministic behaviour, and to have a controlled response. To this end I reached for [Hammox](https://github.com/msz/hammox) for mocking out the API, as I am a fan of typed-contracts. Using Hammox also shines a light on the question of how to deal with applying an inversion-of-control (IoC) style solution to the HTTP(S) client element. It is not the libraries place to dictate choice of client, so by mocking the HTTP(S) client, one is induced to consider how to facilitate allowing end-users to inject their desired HTTP(S) client into the library, whether the client be [Mint](https://github.com/elixir-mint/mint), [Finch](https://github.com/sneako/finch) or custom in-house solution. Another possible alternative would be to use [bypass](https://github.com/PSPDFKit-labs/bypass) which is more oriented towards mocking an HTTP server specifically.

When considering how to best resolve IoC some considerations came to mind. First whether to use application wide configuration similar to `config :your_app, adapter: HttpAdapter`, or call-site configuration in the style of `Client.fetch(HttpAdapter, ...)`. Another possible alternative to an Adapter/behaviour pattern was allowing the user to write a handler function which would then do the actual communication work, similar to `run_finch`[^2] in [req](https://github.com/wojtekmach/req).

A Permit can have one or more facilities, and each facility has has its own location, work day and hours. I am unsure what CNN, NOISent, LocationID, ScheduleID, and the
:@computed_region. schedule property URL doesn't load for the cases I've tried so I have omitted it.

I want to generalize the concepts the library uses to clients and decoder, in particular the idea that users may wish to switch out data sources, which in turn means switching out clients for reading in data, as well as there being a variety of data encodings. The first step to get an idea of the underlying architecture would be to implement a prototype of it (which might or might not be thrown out) for the specific case of using an HTTP source through the Finch library, with JSON encoded data and work out from there. Ideally there would be support for `Stream` style operations. The general pattern might look as follows:

```elixir
def run(client, decoder) do
  client.stream!()
  |> decoder.decode()
  |> data_to_permits()
  |> Enum.to_list()
end
```

[^2]: https://github.com/wojtekmach/req/blob/b09c8861af240e48c63e1da2b7d768a97c14e120/lib/req/steps.ex#L611
