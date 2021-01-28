From: Masahiro Yamada <masahiroy@kernel.org>
Date: Thu, 28 Jan 2021 00:50:48 +0000
Subject: [PATCH 06/27] ARM: syscalls: switch to generic syscalltbl.sh
Message-Id: <20210128005110.2613902-7-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210128005110.2613902-1-masahiroy@kernel.org>
In-Reply-To: <20210128005110.2613902-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org, x86@kernel.org
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, Masahiro Yamada <masahiroy@kernel.org>

As of v5.11-rc1, 12 architectures duplicate similar shell scripts in
order to generate syscall table headers. My goal is to unify them into
the single scripts/syscalltbl.sh.

This commit converts ARM to use scripts/syscalltbl.sh.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

 arch/arm/kernel/entry-common.S |  8 ++++----
 arch/arm/tools/Makefile        |  9 ++++-----
 arch/arm/tools/syscalltbl.sh   | 22 ----------------------
 3 files changed, 8 insertions(+), 31 deletions(-)
 delete mode 100644 arch/arm/tools/syscalltbl.sh

diff --git a/arch/arm/kernel/entry-common.S b/arch/arm/kernel/entry-common.S
index e0d7833a1827..7f0b7aba1498 100644
--- a/arch/arm/kernel/entry-common.S
+++ b/arch/arm/kernel/entry-common.S
@@ -344,20 +344,19 @@ ENTRY(\sym)
 	.size	\sym, . - \sym
 	.endm
 
-#define NATIVE(nr, func) syscall nr, func
+#define __SYSCALL_WITH_COMPAT(nr, native, compat)	__SYSCALL(nr, native)
+#define __SYSCALL(nr, func) syscall nr, func
 
 /*
  * This is the syscall table declaration for native ABI syscalls.
  * With EABI a couple syscalls are obsolete and defined as sys_ni_syscall.
  */
 	syscall_table_start sys_call_table
-#define COMPAT(nr, native, compat) syscall nr, native
 #ifdef CONFIG_AEABI
 #include <calls-eabi.S>
 #else
 #include <calls-oabi.S>
 #endif
-#undef COMPAT
 	syscall_table_end sys_call_table
 
 /*======================================
@@ -455,7 +454,8 @@ ENDPROC(sys_oabi_readahead)
  * using the compatibility syscall entries.
  */
 	syscall_table_start sys_oabi_call_table
-#define COMPAT(nr, native, compat) syscall nr, compat
+#undef __SYSCALL_WITH_COMPAT
+#define __SYSCALL_WITH_COMPAT(nr, native, compat)	__SYSCALL(nr, compat)
 #include <calls-oabi.S>
 	syscall_table_end sys_oabi_call_table
 
diff --git a/arch/arm/tools/Makefile b/arch/arm/tools/Makefile
index 27d8beb7c941..c331cfe92b3c 100644
--- a/arch/arm/tools/Makefile
+++ b/arch/arm/tools/Makefile
@@ -10,7 +10,7 @@ kapi := $(gen)/asm
 uapi := $(gen)/uapi/asm
 syshdr := $(srctree)/$(src)/syscallhdr.sh
 sysnr := $(srctree)/$(src)/syscallnr.sh
-systbl := $(srctree)/$(src)/syscalltbl.sh
+systbl := $(srctree)/scripts/syscalltbl.sh
 syscall := $(srctree)/$(src)/syscall.tbl
 
 gen-y := $(gen)/calls-oabi.S
@@ -47,8 +47,7 @@ quiet_cmd_syshdr = SYSHDR  $@
 		   '__NR_SYSCALL_BASE'
 
 quiet_cmd_systbl = SYSTBL  $@
-      cmd_systbl = $(CONFIG_SHELL) '$(systbl)' '$<' '$@' \
-		   '$(systbl_abi_$(basetarget))'
+      cmd_systbl = $(CONFIG_SHELL) $(systbl) $< $@ $(abis)
 
 quiet_cmd_sysnr  = SYSNR   $@
       cmd_sysnr  = $(CONFIG_SHELL) '$(sysnr)' '$<' '$@' \
@@ -70,10 +69,10 @@ sysnr_abi_unistd-nr := common,oabi,eabi,compat
 $(kapi)/unistd-nr.h: $(syscall) $(sysnr) FORCE
 	$(call if_changed,sysnr)
 
-systbl_abi_calls-oabi := common,oabi
+$(gen)/calls-oabi.S: abis := common,oabi
 $(gen)/calls-oabi.S: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
-systbl_abi_calls-eabi := common,eabi
+$(gen)/calls-eabi.S: abis := common,eabi
 $(gen)/calls-eabi.S: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
diff --git a/arch/arm/tools/syscalltbl.sh b/arch/arm/tools/syscalltbl.sh
deleted file mode 100644
index ae7e93cfbfd3..000000000000
--- a/arch/arm/tools/syscalltbl.sh
+++ /dev/null
@@ -1,22 +0,0 @@
-#!/bin/sh
-# SPDX-License-Identifier: GPL-2.0
-in="$1"
-out="$2"
-my_abis=`echo "($3)" | tr ',' '|'`
-
-grep -E "^[0-9A-Fa-fXx]+[[:space:]]+${my_abis}" "$in" | sort -n | (
-    while read nr abi name entry compat; do
-        if [ "$abi" = "eabi" -a -n "$compat" ]; then
-            echo "$in: error: a compat entry for an EABI syscall ($name) makes no sense" >&2
-            exit 1
-        fi
-
-	if [ -n "$entry" ]; then
-            if [ -z "$compat" ]; then
-                echo "NATIVE($nr, $entry)"
-            else
-                echo "COMPAT($nr, $entry, $compat)"
-            fi
-        fi
-    done
-) > "$out"
-- 
2.27.0
