"""Repository rule that downloads the Chromium Clang toolchain and generates
a BUILD file compatible with toolchains_llvm.

Chromium's Clang tarball layout differs from standard LLVM releases:
- No include/c++/v1/ (Chromium builds libc++ from source)
- No bin/clang-cpp, bin/llvm-profdata, bin/llvm-cov, bin/llvm-as,
  bin/llvm-dwp, bin/llvm-ranlib

This rule patches the download to be compatible with toolchains_llvm's
expected filegroup targets.
"""

_STUB_TOOLS = [
    "clang-cpp",
    "clang-format",
    "clang-tidy",
    "clangd",
    "llvm-as",
    "llvm-cov",
    "llvm-dwp",
    "llvm-objdump",
    "llvm-profdata",
    "llvm-ranlib",
]

_BUILD_FILE_TPL = Label("//:chromium_clang.BUILD.tpl.bzl")

def _chromium_clang_impl(rctx):
    rctx.download_and_extract(
        url = rctx.attr.urls,
        sha256 = rctx.attr.sha256,
        stripPrefix = rctx.attr.strip_prefix,
    )

    rctx.file("include/c++/v1/.keep", "")

    for tool in _STUB_TOOLS:
        path = "bin/" + tool
        if not rctx.path(path).exists:
            rctx.file(
                path,
                '#!/bin/sh\necho "error: {tool} is not included in the Chromium Clang package" >&2\nexit 1\n'.format(tool = tool),
                executable = True,
            )

    llvm_version = "0"
    lib_clang = rctx.path("lib/clang")
    if lib_clang.exists:
        for entry in lib_clang.readdir():
            name = entry.basename
            if name[0].isdigit():
                llvm_version = name
                break

    rctx.template("BUILD.bazel", _BUILD_FILE_TPL, {
        "%{llvm_version}": llvm_version,
    })

chromium_clang = repository_rule(
    implementation = _chromium_clang_impl,
    attrs = {
        "urls": attr.string_list(mandatory = True),
        "sha256": attr.string(default = ""),
        "strip_prefix": attr.string(default = ""),
    },
)
