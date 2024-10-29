
This repository demonstrates Bazel
[configuration transitions](https://bazel.build/extending/config#user-defined-transitions) and their
limitations.

Specifically, it investigates the issue of targets being unnecessarily built multiple times when
transitions are used.

## Repository Strucutre

The repository is divided into four packages:
1. `without_transitions`
2. `with_incoming`
3. `with_incoming_and_outgoing`
4. `with_incoming_and_path_mapping`

Each package separately defines two rules: `static_file` and `copy_file`. `static_file` executes a
single action with no inputs and a single output. `copy_file` executes a single action with a
single input and which produces a single output by copying that input.

While we encourage you to read the `README.md` contained in each package to understand how they use
transitions differently, we provide a brief summary of each package below.

While `without_transitions` defines the rules as you'd expect, `with_incoming` adds an
incoming transition to demonstrate targets being built multiple times in separate
[output directories](https://bazel.build/remote/output-directories), due to the configuration under
which they're built differing. Without the prescence of an
[outgoing transition](https://bazel.build/extending/config#outgoing-edge-transitions) or
[path mapping](https://github.com/bazelbuild/bazel/discussions/22658), Bazel isn't smart enought to
realize that their output can be shared across configurations.

`with_incoming_and_outgoing` and `with_incoming_and_path_mapping` showcase two different approaches
to solving this problem. `with_incoming_and_outgoing` adds an outgoing transition that resets
configuration to its default state across dependency boundaries, ensuring that every target is built
only once. `with_incoming_and_outgoing` leverages path mapping and action deduplication for a more
elegant solution that still allows for a target to be built differently, depending on the
configuration.
