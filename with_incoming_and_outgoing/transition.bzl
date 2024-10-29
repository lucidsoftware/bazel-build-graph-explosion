load(":setting.bzl", "dummy_setting_default")

def _dummy_incoming_transition_impl(settings, attr):
    return {} if attr.dummy_setting == "" else {
        "//with_incoming_and_outgoing:dummy-setting": attr.dummy_setting,
    }

dummy_incoming_transition = transition(
    implementation = _dummy_incoming_transition_impl,
    inputs = [],
    outputs = ["//with_incoming_and_outgoing:dummy-setting"],
)

def _dummy_outgoing_transition_impl(settings, attr):
    return {
        "//with_incoming_and_outgoing:dummy-setting": dummy_setting_default,
    }

dummy_outgoing_transition = transition(
    implementation = _dummy_outgoing_transition_impl,
    inputs = [],
    outputs = ["//with_incoming_and_outgoing:dummy-setting"],
)
