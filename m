From: Masahiro Yamada <masahiroy@kernel.org>
Date: Thu, 28 Jan 2021 00:50:54 +0000
Subject: [PATCH 12/27] m68k: syscalls: switch to generic syscalltbl.sh
Message-Id: <20210128005110.2613902-13-masahiroy@kernel.org>
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

This commit converts m68k to use scripts/syscalltbl.sh.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

 arch/m68k/kernel/syscalls/Makefile      |  7 ++----
 arch/m68k/kernel/syscalls/syscalltbl.sh | 32 -------------------------
 arch/m68k/kernel/syscalltable.S         |  3 +--
 3 files changed, 3 insertions(+), 39 deletions(-)
 delete mode 100644 arch/m68k/kernel/syscalls/syscalltbl.sh

diff --git a/arch/m68k/kernel/syscalls/Makefile b/arch/m68k/kernel/syscalls/Makefile
index 1c42d2d2926d..6610130c67bc 100644
--- a/arch/m68k/kernel/syscalls/Makefile
+++ b/arch/m68k/kernel/syscalls/Makefile
@@ -7,7 +7,7 @@ _dummy := $(shell [ -d '$(uapi)' ] || mkdir -p '$(uapi)')	\
 
 syscall := $(srctree)/$(src)/syscall.tbl
 syshdr := $(srctree)/$(src)/syscallhdr.sh
-systbl := $(srctree)/$(src)/syscalltbl.sh
+systbl := $(srctree)/scripts/syscalltbl.sh
 
 quiet_cmd_syshdr = SYSHDR  $@
       cmd_syshdr = $(CONFIG_SHELL) '$(syshdr)' '$<' '$@'	\
@@ -16,10 +16,7 @@ quiet_cmd_syshdr = SYSHDR  $@
 		   '$(syshdr_offset_$(basetarget))'
 
 quiet_cmd_systbl = SYSTBL  $@
-      cmd_systbl = $(CONFIG_SHELL) '$(systbl)' '$<' '$@'	\
-		   '$(systbl_abis_$(basetarget))'		\
-		   '$(systbl_abi_$(basetarget))'		\
-		   '$(systbl_offset_$(basetarget))'
+      cmd_systbl = $(CONFIG_SHELL) $(systbl) $< $@
 
 $(uapi)/unistd_32.h: $(syscall) $(syshdr) FORCE
 	$(call if_changed,syshdr)
diff --git a/arch/m68k/kernel/syscalls/syscalltbl.sh b/arch/m68k/kernel/syscalls/syscalltbl.sh
deleted file mode 100644
index 85d78d9309ad..000000000000
--- a/arch/m68k/kernel/syscalls/syscalltbl.sh
+++ /dev/null
@@ -1,32 +0,0 @@
-#!/bin/sh
-# SPDX-License-Identifier: GPL-2.0
-
-in="$1"
-out="$2"
-my_abis=`echo "($3)" | tr ',' '|'`
-my_abi="$4"
-offset="$5"
-
-emit() {
-	t_nxt="$1"
-	t_nr="$2"
-	t_entry="$3"
-
-	while [ $t_nxt -lt $t_nr ]; do
-		printf "__SYSCALL(%s, sys_ni_syscall, )\n" "${t_nxt}"
-		t_nxt=$((t_nxt+1))
-	done
-	printf "__SYSCALL(%s, %s, )\n" "${t_nxt}" "${t_entry}"
-}
-
-grep -E "^[0-9A-Fa-fXx]+[[:space:]]+${my_abis}" "$in" | sort -n | (
-	nxt=0
-	if [ -z "$offset" ]; then
-		offset=0
-	fi
-
-	while read nr abi name entry ; do
-		emit $((nxt+offset)) $((nr+offset)) $entry
-		nxt=$((nr+1))
-	done
-) > "$out"
diff --git a/arch/m68k/kernel/syscalltable.S b/arch/m68k/kernel/syscalltable.S
index d329cc7b481c..e25ef4a9df30 100644
--- a/arch/m68k/kernel/syscalltable.S
+++ b/arch/m68k/kernel/syscalltable.S
@@ -18,9 +18,8 @@
 #define sys_mmap2	sys_mmap_pgoff
 #endif
 
-#define __SYSCALL(nr, entry, nargs) .long entry
+#define __SYSCALL(nr, entry) .long entry
 	.section .rodata
 ALIGN
 ENTRY(sys_call_table)
 #include <asm/syscall_table.h>
-#undef __SYSCALL
-- 
2.27.0
