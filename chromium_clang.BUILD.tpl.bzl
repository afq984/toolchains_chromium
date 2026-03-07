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

package(default_visibility = ["//visibility:public"])

exports_files(glob(["bin/*", "lib/**", "include/**", "share/**"], allow_empty = True))

filegroup(
    name = "clang",
    srcs = ["bin/clang", "bin/clang++", "bin/clang-cpp"],
)

filegroup(
    name = "ld",
    srcs = ["bin/ld.lld", "bin/ld64.lld"] + glob(["bin/wasm-ld"], allow_empty = True),
)

filegroup(
    name = "include",
    srcs = glob(["include/**/c++/**", "lib/clang/*/include/**"], allow_empty = True),
)

filegroup(
    name = "all_includes",
    srcs = glob(["include/**"], allow_empty = True),
)

filegroup(
    name = "cxx_builtin_include",
    srcs = glob(["include/c++"], allow_empty = True) + ["lib/clang/%{llvm_version}/include"],
)

filegroup(
    name = "extra_config_site",
    srcs = glob(["include/*/c++/v1/__config_site"], allow_empty = True),
)

filegroup(name = "bin", srcs = glob(["bin/**"]))

filegroup(
    name = "lib",
    srcs = ["lib/clang/%{llvm_version}/lib"] + glob([
        "lib/**/libc++*.a",
        "lib/**/libunwind.a",
    ], allow_empty = True),
)

filegroup(
    name = "lib_legacy",
    srcs = glob([
        "lib/clang/%{llvm_version}/lib/**",
        "lib/**/libc++*.a",
        "lib/**/libunwind.a",
    ], allow_empty = True),
)

filegroup(name = "ar", srcs = ["bin/llvm-ar"])
filegroup(name = "as", srcs = ["bin/clang", "bin/llvm-as"])
filegroup(name = "nm", srcs = ["bin/llvm-nm"])
filegroup(name = "objcopy", srcs = ["bin/llvm-objcopy"])
filegroup(name = "objdump", srcs = ["bin/llvm-objdump"])
filegroup(name = "profdata", srcs = ["bin/llvm-profdata"])
filegroup(name = "dwp", srcs = ["bin/llvm-dwp"])
filegroup(name = "ranlib", srcs = ["bin/llvm-ranlib"])
filegroup(name = "readelf", srcs = ["bin/llvm-readelf"])
filegroup(name = "strip", srcs = ["bin/llvm-strip"])
filegroup(name = "symbolizer", srcs = ["bin/llvm-symbolizer"])
