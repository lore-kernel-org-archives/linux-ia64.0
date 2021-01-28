From: Masahiro Yamada <masahiroy@kernel.org>
Date: Thu, 28 Jan 2021 00:50:57 +0000
Subject: [PATCH 15/27] mips: add missing FORCE and fix 'targets' to make if_changed work
Message-Id: <20210128005110.2613902-16-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210128005110.2613902-1-masahiroy@kernel.org>
In-Reply-To: <20210128005110.2613902-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org, x86@kernel.org
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, Masahiro Yamada <masahiroy@kernel.org>

The rules in this Makefile cannot detect the command line change because
the prerequisite 'FORCE' is missing.

Adding 'FORCE' will result in the headers being rebuilt every time
because the 'targets' addition is also wrong; the file paths in
'targets' must be relative to the current Makefile.

Fix all of them so the if_changed rules work correctly.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

 arch/mips/kernel/syscalls/Makefile | 27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/arch/mips/kernel/syscalls/Makefile b/arch/mips/kernel/syscalls/Makefile
index 6efb2f6889a7..f15842bda464 100644
--- a/arch/mips/kernel/syscalls/Makefile
+++ b/arch/mips/kernel/syscalls/Makefile
@@ -31,50 +31,50 @@ quiet_cmd_systbl = SYSTBL  $@
 		   '$(systbl_offset_$(basetarget))'
 
 syshdr_offset_unistd_n32 := __NR_Linux
-$(uapi)/unistd_n32.h: $(syscalln32) $(syshdr)
+$(uapi)/unistd_n32.h: $(syscalln32) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
 syshdr_offset_unistd_n64 := __NR_Linux
-$(uapi)/unistd_n64.h: $(syscalln64) $(syshdr)
+$(uapi)/unistd_n64.h: $(syscalln64) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
 syshdr_offset_unistd_o32 := __NR_Linux
-$(uapi)/unistd_o32.h: $(syscallo32) $(syshdr)
+$(uapi)/unistd_o32.h: $(syscallo32) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
 sysnr_pfx_unistd_nr_n32 := N32
 sysnr_offset_unistd_nr_n32 := 6000
-$(uapi)/unistd_nr_n32.h: $(syscalln32) $(sysnr)
+$(uapi)/unistd_nr_n32.h: $(syscalln32) $(sysnr) FORCE
 	$(call if_changed,sysnr)
 
 sysnr_pfx_unistd_nr_n64 := 64
 sysnr_offset_unistd_nr_n64 := 5000
-$(uapi)/unistd_nr_n64.h: $(syscalln64) $(sysnr)
+$(uapi)/unistd_nr_n64.h: $(syscalln64) $(sysnr) FORCE
 	$(call if_changed,sysnr)
 
 sysnr_pfx_unistd_nr_o32 := O32
 sysnr_offset_unistd_nr_o32 := 4000
-$(uapi)/unistd_nr_o32.h: $(syscallo32) $(sysnr)
+$(uapi)/unistd_nr_o32.h: $(syscallo32) $(sysnr) FORCE
 	$(call if_changed,sysnr)
 
 systbl_abi_syscall_table_32_o32 := 32_o32
 systbl_offset_syscall_table_32_o32 := 4000
-$(kapi)/syscall_table_32_o32.h: $(syscallo32) $(systbl)
+$(kapi)/syscall_table_32_o32.h: $(syscallo32) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 systbl_abi_syscall_table_64_n32 := 64_n32
 systbl_offset_syscall_table_64_n32 := 6000
-$(kapi)/syscall_table_64_n32.h: $(syscalln32) $(systbl)
+$(kapi)/syscall_table_64_n32.h: $(syscalln32) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 systbl_abi_syscall_table_64_n64 := 64_n64
 systbl_offset_syscall_table_64_n64 := 5000
-$(kapi)/syscall_table_64_n64.h: $(syscalln64) $(systbl)
+$(kapi)/syscall_table_64_n64.h: $(syscalln64) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 systbl_abi_syscall_table_64_o32 := 64_o32
 systbl_offset_syscall_table_64_o32 := 4000
-$(kapi)/syscall_table_64_o32.h: $(syscallo32) $(systbl)
+$(kapi)/syscall_table_64_o32.h: $(syscallo32) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 uapisyshdr-y		+= unistd_n32.h			\
@@ -88,9 +88,10 @@ kapisyshdr-y		+= syscall_table_32_o32.h	\
 			   syscall_table_64_n64.h	\
 			   syscall_table_64_o32.h
 
-targets	+= $(uapisyshdr-y) $(kapisyshdr-y)
+uapisyshdr-y	:= $(addprefix $(uapi)/, $(uapisyshdr-y))
+kapisyshdr-y	:= $(addprefix $(kapi)/, $(kapisyshdr-y))
+targets		+= $(addprefix ../../../../, $(uapisyshdr-y) $(kapisyshdr-y))
 
 PHONY += all
-all: $(addprefix $(uapi)/,$(uapisyshdr-y))
-all: $(addprefix $(kapi)/,$(kapisyshdr-y))
+all: $(uapisyshdr-y) $(kapisyshdr-y)
 	@:
-- 
2.27.0
