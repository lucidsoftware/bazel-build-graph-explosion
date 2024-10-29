# `with_incoming_and_path_mapping`

This package leverages [path mapping](https://github.com/bazelbuild/bazel/discussions/22658) and
action deduplication so that:
- Targets are re-built when the configuration matters
- Targets aren't re-built when the configuration doesn't matter

```diff
$ diff --exclude README.md with_incoming with_incoming_and_path_mapping
diff --exclude README.md with_incoming/BUILD.bazel with_incoming_and_path_mapping/BUILD.bazel
8a9,22
> config_setting(
>     name = "dummy-setting-foo",
>     flag_values = {
>         ":dummy-setting": "foo",
>     },
> )
>
> config_setting(
>     name = "dummy-setting-bar",
>     flag_values = {
>         ":dummy-setting": "bar",
>     },
> )
>
22a37,51
> )
>
> static_file(
>     name = "dynamic-file",
>     content = select({
>         ":dummy-setting-foo": "The setting is foo.",
>         ":dummy-setting-bar": "The setting is bar.",
>         "//conditions:default": "The setting is neither foo, nor bar.",
>     }),
> )
>
> copy_file(
>     name = "copied-dynamic-file",
>     dummy_setting = "bar",
>     input = ":dynamic-file",
diff --exclude README.md with_incoming/rules.bzl with_incoming_and_path_mapping/rules.bzl
11a12,14
>         execution_requirements = {
>             "supports-path-mapping": "1",
>         },
33a37,39
>         execution_requirements = {
>             "supports-path-mapping": "1",
>         },
diff --exclude README.md with_incoming/transition.bzl with_incoming_and_path_mapping/transition.bzl
3c3
<         "//with_incoming:dummy-setting": attr.dummy_setting,
---
>         "//with_incoming_and_path_mapping:dummy-setting": attr.dummy_setting,
9c9
<     outputs = ["//with_incoming:dummy-setting"],
---
>     outputs = ["//with_incoming_and_path_mapping:dummy-setting"],
```

From the GitHub discussion on path mapping linked above:

> With path mapping enabled, Bazel automatically rewrites paths in action command lines with the aim
> of making them more likely to be disk or remote cache hits.
>
> Specifically, configuration prefixes such as `bazel-out/darwin-amd64-fastbuild/bin` are replaced
> with a fixed string such as `bazel-out/cfg/bin`, so that the result of an action that doesn't
> depend on all aspects of the configuration encoded in the path (e.g. the OS, architecture and
> build mode) can be shared between different target platforms and configurations.

With this package, we've made a few changes:
- Path mapping is enabled via `--experimental_output_paths=strip` (see [.bazelrc](../.bazelrc))
- `copy_file` explicitly opts in to path mapping (this is required for it to be used)
- We've enabled a disk cache (see [.bazelrc](../.bazelrc))

You'll notice that two actions are produced for `:file`, and they still have different
[action keys](https://bazel.build/reference/glossary#action-key):

```
$ bazel aquery 'mnemonic("^StaticFile$", deps(//with_incoming_and_path_mapping:copied-file + //with_incoming_and_path_mapping:copied-file-with-transition))' 2> /dev/null
action 'StaticFile with_incoming_and_path_mapping/file/output.txt'
  Mnemonic: StaticFile
  Target: //with_incoming_and_path_mapping:file
  Configuration: k8-fastbuild-ST-1ced54a1a14e
  Execution platform: @platforms//host:host
  ActionKey: 5a0573f261bcdcaebf0ebb794cb47ae1604d81ac04af915c7708125bdc21628f
  Inputs: []
  Outputs: [bazel-out/k8-fastbuild-ST-1ced54a1a14e/bin/with_incoming_and_path_mapping/file/output.txt]
  Command Line: (exec /bin/bash \
    -c \
    'echo '\''Generating static file...'\''; echo "$1" > "$2"' \
    '' \
    'Hello, world!' \
    bazel-out/cfg/bin/with_incoming_and_path_mapping/file/output.txt)
# Configuration: e0e4f3ca73f227d05488bf1630f81adf64d705277a81fc9bef3b9807dddc19ed
# Execution platform: @@platforms//host:host
  ExecutionInfo: {supports-path-mapping: 1}

action 'StaticFile with_incoming_and_path_mapping/file/output.txt'
  Mnemonic: StaticFile
  Target: //with_incoming_and_path_mapping:file
  Configuration: k8-fastbuild
  Execution platform: @platforms//host:host
  ActionKey: 2b377853a483cc17d98fae4fb46f390c26acbce28c4f63f72ac66bac83be650d
  Inputs: []
  Outputs: [bazel-out/k8-fastbuild/bin/with_incoming_and_path_mapping/file/output.txt]
  Command Line: (exec /bin/bash \
    -c \
    'echo '\''Generating static file...'\''; echo "$1" > "$2"' \
    '' \
    'Hello, world!' \
    bazel-out/cfg/bin/with_incoming_and_path_mapping/file/output.txt)
# Configuration: c1d7d5ec98965ef297d5c260736c24f7fcb9fd5039103a0c4ab253e2b94ae32b
# Execution platform: @@platforms//host:host
  ExecutionInfo: {supports-path-mapping: 1}
```

However, as of Bazel v7.4.0, these actions will be "deduplicated" because their commands are
identical, causing only one of them to be executed. Notice the `1 deduplicated`:

```
$ bazel clean
$ bazel build //with_incoming_and_path_mapping:copied-file //with_incoming_and_path_mapping:copied-file-with-transition
INFO: Invocation ID: 40df9e0d-d9d5-4ee4-8297-2b29af0a481a
INFO: Analyzed 2 targets (6 packages loaded, 13 targets configured).
INFO: From StaticFile with_incoming_and_path_mapping/file/output.txt:
Generating static file...
INFO: From StaticFile with_incoming_and_path_mapping/file/output.txt:
Generating static file...
INFO: Found 2 targets...
INFO: Elapsed time: 0.167s, Critical Path: 0.02s
INFO: 5 processes: 1 internal, 1 deduplicated, 3 linux-sandbox.
INFO: Build completed successfully, 5 total actions
```

Additionally, `:copied-dynamic-file` is now built correctly:

```
$ bazel build //with_incoming_and_path_mapping:copied-dynamic-file
$ cat bazel-bin/with_incoming_and_path_mapping/copied-dynamic-file/output.txt.copy
The setting is bar.
```
