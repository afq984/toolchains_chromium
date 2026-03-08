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

"""Repository rule that downloads a Chromium sysroot tarball."""

def _chromium_sysroot_impl(rctx):
    rctx.download_and_extract(
        url = rctx.attr.urls,
        sha256 = rctx.attr.sha256,
        output = "sysroot",
        type = "tar.xz",
    )

    # Use srcs = ["."] (source directory) instead of glob(["**"]) to avoid
    # issues with filenames containing backslashes and for better sandbox perf.
    rctx.file("sysroot/BUILD.bazel", 'filegroup(name = "sysroot", srcs = ["."], visibility = ["//visibility:public"])\n')
    rctx.file("BUILD.bazel", "")

chromium_sysroot = repository_rule(
    implementation = _chromium_sysroot_impl,
    attrs = {
        "urls": attr.string_list(mandatory = True),
        "sha256": attr.string(default = ""),
    },
)
