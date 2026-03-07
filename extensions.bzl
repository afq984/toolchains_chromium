# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Module extension for the Chromium C++ toolchain.

Consuming teams use this to get Chromium's Clang + Debian sysroot
configured as a Bazel C++ toolchain with minimal boilerplate.
"""

load("@toolchains_llvm//toolchain:rules.bzl", "llvm_toolchain")
load("@toolchains_llvm//toolchain:sysroot.bzl", "sysroot")
load("//:chromium_clang.bzl", "chromium_clang")
load(
    "//:defaults.bzl",
    "CLANG_SHA256",
    "CLANG_URLS",
    "LLVM_MAJOR_VERSION",
    "SYSROOT_SHA256",
    "SYSROOT_URLS",
)

def _chromium_impl(module_ctx):
    # Construct canonical labels that bypass toolchains_llvm's repo mapping.
    # We need these because toolchain_roots/sysroot are string-typed attrs
    # resolved inside toolchains_llvm's repo rule context, not ours.
    #
    # The canonical name format (@@module++extension+repo) is explicitly
    # unstable (https://github.com/bazelbuild/bazel/issues/23127) but there
    # is no stable API to avoid it (https://github.com/bazelbuild/bazel/issues/19055).
    # toolchains_llvm itself relies on the same format in configure.bzl.
    module_name = Label("//:BUILD.bazel").repo_name.removesuffix("+")

    # Extension repos are: @@{module}++{extension}+{repo}
    ext_prefix = module_name + "++chromium+"

    for mod in module_ctx.modules:
        if not mod.is_root:
            fail("Only the root module can use the 'chromium' extension")

        for tag in mod.tags.toolchain:
            name = tag.name
            targets = tag.targets if tag.targets else ["linux-x86_64"]

            # Download Chromium Clang.
            clang_name = name + "_clang"
            clang_urls = tag.clang_urls if tag.clang_urls else CLANG_URLS.get("linux-x86_64", [])
            clang_sha256 = tag.clang_sha256 if tag.clang_sha256 else CLANG_SHA256.get("linux-x86_64", "")

            chromium_clang(
                name = clang_name,
                urls = clang_urls,
                sha256 = clang_sha256,
            )

            # Download sysroots for each target.
            sysroot_dict = {}
            for target in targets:
                sysroot_name = name + "_sysroot_" + target.replace("-", "_")
                sysroot_urls = SYSROOT_URLS.get(target)
                sysroot_sha = SYSROOT_SHA256.get(target, "")

                if not sysroot_urls:
                    fail("No sysroot available for target: %s" % target)

                sysroot(
                    name = sysroot_name,
                    urls = sysroot_urls,
                    sha256 = sysroot_sha,
                )
                sysroot_dict[target] = "@@%s%s//sysroot" % (ext_prefix, sysroot_name)

            # Use canonical labels so toolchains_llvm's repo rule can resolve them.
            clang_canonical = "@@%s%s//" % (ext_prefix, clang_name)

            # Wire up toolchains_llvm.
            llvm_toolchain(
                name = name,
                llvm_versions = {"": "%s.0.0" % LLVM_MAJOR_VERSION},
                toolchain_roots = {"": clang_canonical},
                sysroot = sysroot_dict,
                # Chromium's Clang tarball doesn't ship libc++ headers;
                # link against the sysroot's libstdc++ instead.
                stdlib = {"": "dynamic-stdc++"},
                cxx_builtin_include_directories = {
                    target: [
                        "%%workspace%%/lib/clang/%s/include" % LLVM_MAJOR_VERSION,
                    ]
                    for target in targets
                },
            )

chromium = module_extension(
    implementation = _chromium_impl,
    tag_classes = {
        "toolchain": tag_class(
            attrs = {
                "name": attr.string(
                    default = "chromium_toolchain",
                    doc = "Name for the generated toolchain repos.",
                ),
                "targets": attr.string_list(
                    doc = 'Target platforms. Default: ["linux-x86_64"].',
                ),
                "clang_urls": attr.string_list(
                    doc = "Override Clang download URLs.",
                ),
                "clang_sha256": attr.string(
                    doc = "Override Clang tarball sha256.",
                ),
            },
        ),
    },
)
