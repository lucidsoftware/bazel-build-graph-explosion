# bazel-build-graph-explosion

This repository demonstrates [toolchains](https://bazel.build/extending/toolchains) and
[configuration transitions](https://bazel.build/extending/config#user-defined-transitions) in Bazel,
and their limitations.

## Repository Strucutre

The repository is divided into two packages:
- `with_toolchains`
- `without_toolchains`

Both packages contain separate of implementations of the `greeting` rule, which accepts a subject
and outputs a file containing a greeting addressed to that subject:

```
$ bazel build //without_toolchains:hello-world
$ cat bazel-bin/without_toolchains/hello-world_greeting.txt
Hello, world!
```

Greetings can also have dependencies, in which case those dependencies' subjects will be added to
the greeting:

```
$ bazel build //without_toolchains:hello-jaden-and-world
$ cat bazel-bin/without_toolchains/hello-jaden-and-world_greeting.txt
Hello, Jaden! Also, hello to world.
```

The core difference between `without_toolchains` and `with_toolchains` is that in the former, the
subject is provided as an attribute, whereas in the latter, it's provided as a toolchain.

## Build Graph Redundancies

Often, we talk about "multiple versions" of a package being built. To see what's meant by that, run:

```sh
bazel cquery 'kind("^greeting(_with_outgoing_transition)? rule$", //with_toolchains:*)' --output graph |
    dot -Grankdir=LR -Tsvg
```

to generate an SVG of the build graph for the `with_toolchains` package:

![`with_toolchains` build graph](graphs/with_toolchains.svg)

Note that this is distinct from the dependency graph, which can be viewed with:

```sh
bazel query 'kind("^greeting(_with_outgoing_transition)? rule$", //with_toolchains/...)' \
    --output graph \
    --nograph:factored
```

The build graph is built at [analysis-time](https://bazel.build/extending/concepts#evaluation-model)
and takes configuration into account. The dependency graph is built at loading time and doesn't.

Notice how every target has a single node in the dependency graph, but
potentially multipe targets in the build graph. `with_toolchains/BUILD.bazel` explains why some
targets are unnecessarily built multiple times and how that can be mitigated. Also notice how when
toolchains and configuration transitions aren't used, every target has a single node in the
build graph:

```sh
bazel cquery 'kind("^greeting rule$", //without_toolchains:*)' --output graph | dot -Grankdir=LR -Tsvg
```

![`without_toolchains` build graph](graphs/without_toolchains.svg)
