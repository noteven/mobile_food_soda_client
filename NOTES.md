# Notes
These notes are provided in satisfaction of the requirement for a documented though process as per the
[PROBLEM_STATEMENT.md](PROBLEM_STATEMENT.md) file.

## Project definition
Initially the only idea that came to mind was front-end oriented projects such as data visualization or querying, but both
of these functionalities were already well supported - San Franciscos' Mobile Food Facility Permit [SODA API](https://data.sfgov.org/resource/rqzj-sfat.json), hence forth
the API, supports robust querying and theres a somewhat functional Maps style visualization available. As happens when
searching for a problem to a solution I was trying to come up with a problem that would allow me to utilize [Broadway](https://github.com/dashbitco/broadway), [libCluster](https://github.com/bitwalker/libcluster),
[Ecto](https://github.com/elixir-ecto/ecto), or Erlang Term Storage ([ETS](https://www.erlang.org/doc/man/ets.html)). Thinking about it I decided that no matter what I decided to implement, I would need
a client to the API, so I might as well start from there.

In all honesty I don't expect to be able to actually develop a project using the client, but if I did, I would probably
try implementing something that simply takes messages on a Broadway pipeline and uses the client to query the
information from the SODA API. Hopefully going that route I'd get to look into using Kubernetes and libCluster for
distributed Elixir, which in turn would mean looking into distributed tracing, Grafana and possibly Terraform. This would
provide a fertile bed for exploring new technologies/skills, but for which a non-negligible amount of time would be required.

## Project Set-up
First step is setting up project, that means setting up basic developer code-quality tooling (credo, dialyzer), git
files (.gitignore), and Github Workflow for continuous integration and continuous delivery (CI/CD). As this project is
implementing a library, the CD portion is not applicable (no formal releases). Furthermore a permissive software license
is chosen (MIT) and a .editorconfig is provided for completion of basic project layout.

During setting-up CI/CD it is necessary to pay attention to caching for not only dependencies but Dialyzer to bring down
the runtime. Managing build/test times is important as Workflow is billed/tiered by minutes[^1], and in developer workflow
fast turnaround time is important for developer experience.

This work culminated in commit 64984265274136e2344dcc360d86864e2b8ef8e3 which set-up the main branch for use in
Github Flow style development (feature/hotfix branching). Feature branches may now be created, merged in and tested
automatically.

[^1]: https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions

## First features
Development continues by writing out some basic tests to help guide software architecture/design decisions by looking at
it from an end-user (developer) ergonomics point of view. Further along the process I expect tests to document use-cases,
edge-cases and fuzz the system input/output; this should help document behaviour, reveal abnormal behaviour and provide
a framework for preventing regressions/bugs.

The first step is the basic behaviour of hitting the San Franciscos' [Mobile Food Facility Permit data-set](https://data.sfgov.org/resource/rqzj-sfat.json) SODA API,
henceforth the end-point, and retrieving the results. This requires setting up a test to simulate using the client to fetch
results, which in turn means utilizing a test double for the SODA API to prevent un-deterministic behaviour, and to have
a controlled response. To this end I reached for [Hammox](https://github.com/msz/hammox) for mocking out the API, as I
am a fan of typed-contracts.

Using Hammox also shines a light on the question of how to deal with applying an inversion-of-control (IoC) style solution to
the HTTP(S) client element. It is not the libraries place to dictate choice of client, so by mocking the HTTP(S) client,
one is induced to consider how to facilitate allowing end-users to inject their desired HTTP(S) client into the library,
whether the client be [Mint](https://github.com/elixir-mint/mint), [Finch](https://github.com/sneako/finch) or custom
in-house solution.
