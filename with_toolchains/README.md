# Package Description

This package contains various targets which demonstrate flaws in how Bazel handles configuration.
See `BUILD.bazel` for more information.

Often, we talk about "multiple versions" of a package being built. To see what's meant by that, run:
```
bazel cquery 'kind("greeting", //with_toolchains/...)' --output graph --nograph:factored
```

to view the build graph for this package. Note that this is distinct from the dependency graph,
which can be viewed with:
```
bazel query 'kind("greeting", //with_toolchains/...)' --output graph --nograph:factored
```

The build graph is built at [analysis-time](https://bazel.build/extending/concepts#evaluation-model)
and takes configuration into account. The dependency graph is built at loading time and includes
only one node per target.
