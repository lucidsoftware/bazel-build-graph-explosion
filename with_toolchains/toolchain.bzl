def _greeting_subject_impl(ctx):
    return [
        platform_common.ToolchainInfo(
            subject = ctx.attr.subject,
        ),
    ]

greeting_subject = rule(
    implementation = _greeting_subject_impl,
    attrs = {
        "subject": attr.string(mandatory = True),
    },
)

def greeting_toolchain(name, **kwargs):
    greeting_subject(
        name = "{}-subject".format(name),
        **kwargs,
    )

    native.config_setting(
        name = "{}-setting".format(name),
        flag_values = {
            "//with_toolchains:greeting-toolchain": name,
        },
    )

    native.toolchain(
        name = name,
        target_settings = [":{}-setting".format(name)],
        toolchain = ":{}-subject".format(name),
        toolchain_type = "//with_toolchains:toolchain_type",
    )
