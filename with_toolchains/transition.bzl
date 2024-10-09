load(":toolchain_default.bzl", "default_greeting_toolchain_name")

def _greeting_incoming_transition_impl(_, attr):
    if attr.toolchain_name == "":
        return {}

    return {
        "//with_toolchains:greeting-toolchain": attr.toolchain_name,
    }

greeting_incoming_transition = transition(
    implementation = _greeting_incoming_transition_impl,
    inputs = [],
    outputs = ["//with_toolchains:greeting-toolchain"],
)

def _greeting_outgoing_transition_impl(_1, _2):
    return {
        "//with_toolchains:greeting-toolchain": default_greeting_toolchain_name,
    }

greeting_outgoing_transition = transition(
    implementation = _greeting_outgoing_transition_impl,
    inputs = [],
    outputs = ["//with_toolchains:greeting-toolchain"],
)
