def _dummy_incoming_transition_impl(settings, attr):
    return {} if attr.dummy_setting == "" else {
        "//with_incoming:dummy-setting": attr.dummy_setting,
    }

dummy_incoming_transition = transition(
    implementation = _dummy_incoming_transition_impl,
    inputs = [],
    outputs = ["//with_incoming:dummy-setting"],
)
