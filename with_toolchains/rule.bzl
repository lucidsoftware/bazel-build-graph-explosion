load(":transition.bzl", "greeting_incoming_transition", "greeting_outgoing_transition")

GreetingInfo = provider(
    fields = ["subjects"],
)

def _greeting_impl(ctx):
    subject = ctx.toolchains[":toolchain_type"].subject
    additional_subjects = []

    for dependency in ctx.attr.deps:
        additional_subjects.extend(dependency[GreetingInfo].subjects)

    output = ctx.actions.declare_file("{}_greeting.txt".format(ctx.label.name))

    if additional_subjects == []:
        output_content = "Hello, {}!\n".format(subject)
    else:
        output_content = \
            "Hello, {}! Also, hello to {}.\n".format(subject, ", ".join(additional_subjects))

    ctx.actions.write(output, output_content)

    return [
        GreetingInfo(
            subjects = additional_subjects + [subject],
        ),

        DefaultInfo(
            files = depset([output]),
        )
    ]

greeting = rule(
    attrs = {
        "deps": attr.label_list(
            providers = [GreetingInfo],
        ),

        "toolchain_name": attr.string(),
    },

    cfg = greeting_incoming_transition,
    implementation = _greeting_impl,
    toolchains = [":toolchain_type"],
)

greeting_with_outgoing_transition = rule(
    attrs = {
        "deps": attr.label_list(
            cfg = greeting_outgoing_transition,
            providers = [GreetingInfo],
        ),

        "toolchain_name": attr.string(),
    },

    cfg = greeting_incoming_transition,
    implementation = _greeting_impl,
    toolchains = [":toolchain_type"],
)

def _toolchainless_greeting_impl(ctx):
    return [
        GreetingInfo(
            subjects = [],
        ),
    ]

toolchainless_greeting = rule(
    implementation = _toolchainless_greeting_impl,
)
