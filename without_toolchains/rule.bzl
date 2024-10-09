GreetingInfo = provider(
    fields = ["subjects"],
)

def _greeting_impl(ctx):
    additional_subjects = []

    for dependency in ctx.attr.deps:
        additional_subjects.extend(dependency[GreetingInfo].subjects)

    output = ctx.actions.declare_file("{}_greeting.txt".format(ctx.label.name))

    if additional_subjects == []:
        output_content = "Hello, {}!\n".format(ctx.attr.subject)
    else:
        output_content = "Hello, {}! Also, hello to {}.\n".format(
            ctx.attr.subject,
            ", ".join(additional_subjects),
        )

    ctx.actions.write(output, output_content)

    return [
        GreetingInfo(
            subjects = additional_subjects + [ctx.attr.subject],
        ),

        DefaultInfo(
            files = depset([output]),
        )
    ]

greeting = rule(
    implementation = _greeting_impl,
    attrs = {
        "deps": attr.label_list(
            providers = [GreetingInfo],
        ),

        "subject": attr.string(mandatory = True),
    },
)
