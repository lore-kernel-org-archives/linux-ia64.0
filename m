From: zsugabubus <zsugabubus@national.shitposting.agency>
Date: Wed, 22 Apr 2020 00:53:59 +0000
Subject: [PATCH] ia64: fix word quoting in shell scripts
Message-Id: <20200422005359.c6vh2jblrevznjml@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Previous implementation did not quote some variables that could be
potentially empty, for example due to a failed compilation. It made
test(1) failing but desired error action was not taken.

Cleaning of temporary files is also been made a bit more robust.
---
 arch/ia64/scripts/check-gas       | 25 ++++++++--------
 arch/ia64/scripts/toolchain-flags | 50 ++++++++++++++-----------------
 2 files changed, 36 insertions(+), 39 deletions(-)

diff --git a/arch/ia64/scripts/check-gas b/arch/ia64/scripts/check-gas
index 787cf9b6b..7210522e6 100755
--- a/arch/ia64/scripts/check-gas
+++ b/arch/ia64/scripts/check-gas
@@ -1,16 +1,17 @@
 #!/bin/sh
 # SPDX-License-Identifier: GPL-2.0
-dir=$(dirname $0)
 CC=$1
 OBJDUMP=$2
-tmp=${TMPDIR:-/tmp}
-out=$tmp/out$$.o
-$CC -c $dir/check-gas-asm.S -o $out
-res=$($OBJDUMP -r --section .data $out | fgrep 00004 | tr -s ' ' |cut -f3 -d' ')
-rm -f $out
-if [ $res != ".text" ]; then
-	echo buggy
-else
-	echo good
-fi
-exit 0
+
+cd "$(dirname $0)"
+
+tmp=${TMPDIR:-/tmp}/check-gas-$$.o
+trap 'rm -f "$tmp"' INT TERM EXIT
+
+$CC -c check-gas-asm.S -o "$tmp" &&
+$OBJDUMP -r --section .data "$tmp" \
+| fgrep 00004 | tr -s ' ' | cut -f3 -d' ' \
+| {
+  read -r section
+  [ "$section" = .text ] && echo good
+} || echo buggy
diff --git a/arch/ia64/scripts/toolchain-flags b/arch/ia64/scripts/toolchain-flags
index 12dff5c98..4bfa4d6d6 100755
--- a/arch/ia64/scripts/toolchain-flags
+++ b/arch/ia64/scripts/toolchain-flags
@@ -7,48 +7,44 @@ CPPFLAGS=""
 CC=$1
 OBJDUMP=$2
 READELF=$3
-dir=$(dirname $0)
-tmp=${TMPDIR:-/tmp}
-out=$tmp/out$$
+
+cd "$(dirname $0)"
+
+tmp=${TMPDIR:-/tmp}/toolchain-flags-$$
+trap 'rm -f "$tmp"' INT TERM EXIT
 
 # Check whether cross-segment segment-relative relocs work fine.  We need
 # that for building the gate DSO:
-
-$CC -nostdlib -static -Wl,-T$dir/check-segrel.lds $dir/check-segrel.S -o $out
-res=$($OBJDUMP --full --section .rodata $out | fgrep 000 | cut -f3 -d' ')
-rm -f $out
-if [ $res != 00000a00 ]; then
-    CPPFLAGS="$CPPFLAGS -DHAVE_BUGGY_SEGREL"
-    cat >&2 <<EOF
+$CC -nostdlib -static -Wl,-Tcheck-segrel.lds check-segrel.S -o "$tmp" &&
+$OBJDUMP --full --section .rodata "$tmp" | fgrep 000 | cut -f3 -d' ' \
+| {
+  read -r addr
+  [ "$addr" = 00000a00 ]
+} || {
+  CPPFLAGS="$CPPFLAGS -DHAVE_BUGGY_SEGREL"
+  cat >&2 <<EOF
 warning: your linker cannot handle cross-segment segment-relative relocations.
          please upgrade to a newer version (it is safe to use this linker, but
          the kernel will be bigger than strictly necessary).
 EOF
-fi
+}
 
 # Check whether .align inside a function works as expected.
-
-$CC -c $dir/check-text-align.S -o $out
-$READELF -u $out | fgrep -q 'prologue(rlen)'
-res=$?
-rm -f $out
-if [ $res -eq 0 ]; then
-    CPPFLAGS="$CPPFLAGS -DHAVE_WORKING_TEXT_ALIGN"
+if $CC -c check-text-align.S -o "$tmp" && \
+   $READELF -u "$tmp" | fgrep -q 'prologue(rlen)'
+then
+  CPPFLAGS="$CPPFLAGS -DHAVE_WORKING_TEXT_ALIGN"
 fi
 
-if ! $CC -c $dir/check-model.c -o $out 2>&1 | grep  __model__ | grep -q attrib
+if ! $CC -c check-model.c -o "$tmp" 2>&1 | grep  __model__ | grep -q attrib
 then
-    CPPFLAGS="$CPPFLAGS -DHAVE_MODEL_SMALL_ATTRIBUTE"
+  CPPFLAGS="$CPPFLAGS -DHAVE_MODEL_SMALL_ATTRIBUTE"
 fi
-rm -f $out
 
 # Check whether assembler supports .serialize.{data,instruction} directive.
-
-$CC -c $dir/check-serialize.S -o $out 2>/dev/null
-res=$?
-rm -f $out
-if [ $res -eq 0 ]; then
-    CPPFLAGS="$CPPFLAGS -DHAVE_SERIALIZE_DIRECTIVE"
+if $CC -c check-serialize.S -o "$tmp" 2>/dev/null
+then
+  CPPFLAGS="$CPPFLAGS -DHAVE_SERIALIZE_DIRECTIVE"
 fi
 
 echo $CPPFLAGS
-- 
2.26.1
