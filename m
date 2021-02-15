From: Masahiro Yamada <masahiroy@kernel.org>
Date: Mon, 15 Feb 2021 00:48:22 +0000
Subject: [PATCH 1/2] arch: syscalls: add missing FORCE and fix 'targets' to make if_changed work
Message-Id: <20210215004823.440102-1-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: Masahiro Yamada <masahiroy@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Borislav Petkov <bp@alien8.de>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Helge Deller <deller@gmx.de>, Ingo Molnar <mingo@redhat.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Richard Henderson <rth@twiddle.net>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, x86@kernel.org

The rules in these Makefiles cannot detect the command line change
because the prerequisite 'FORCE' is missing.

Adding 'FORCE' will result in the headers being rebuilt every time
because the 'targets' additions are also wrong; the file paths in
'targets' must be relative to the current Makefile.

Fix all of them so the if_changed rules work correctly.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
---

 arch/alpha/kernel/syscalls/Makefile      | 11 +++++-----
 arch/ia64/kernel/syscalls/Makefile       | 11 +++++-----
 arch/m68k/kernel/syscalls/Makefile       | 11 +++++-----
 arch/microblaze/kernel/syscalls/Makefile | 11 +++++-----
 arch/mips/kernel/syscalls/Makefile       | 27 ++++++++++++------------
 arch/parisc/kernel/syscalls/Makefile     | 17 ++++++++-------
 arch/powerpc/kernel/syscalls/Makefile    | 19 +++++++++--------
 arch/sh/kernel/syscalls/Makefile         | 11 +++++-----
 arch/sparc/kernel/syscalls/Makefile      | 17 ++++++++-------
 arch/x86/entry/syscalls/Makefile         | 23 ++++++++++----------
 arch/xtensa/kernel/syscalls/Makefile     | 11 +++++-----
 11 files changed, 90 insertions(+), 79 deletions(-)

diff --git a/arch/alpha/kernel/syscalls/Makefile b/arch/alpha/kernel/syscalls/Makefile
index 659faefdcb1d..1c42d2d2926d 100644
--- a/arch/alpha/kernel/syscalls/Makefile
+++ b/arch/alpha/kernel/syscalls/Makefile
@@ -21,18 +21,19 @@ quiet_cmd_systbl = SYSTBL  $@
 		   '$(systbl_abi_$(basetarget))'		\
 		   '$(systbl_offset_$(basetarget))'
 
-$(uapi)/unistd_32.h: $(syscall) $(syshdr)
+$(uapi)/unistd_32.h: $(syscall) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
-$(kapi)/syscall_table.h: $(syscall) $(systbl)
+$(kapi)/syscall_table.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 uapisyshdr-y		+= unistd_32.h
 kapisyshdr-y		+= syscall_table.h
 
-targets	+= $(uapisyshdr-y) $(kapisyshdr-y)
+uapisyshdr-y	:= $(addprefix $(uapi)/, $(uapisyshdr-y))
+kapisyshdr-y	:= $(addprefix $(kapi)/, $(kapisyshdr-y))
+targets		+= $(addprefix ../../../../, $(uapisyshdr-y) $(kapisyshdr-y))
 
 PHONY += all
-all: $(addprefix $(uapi)/,$(uapisyshdr-y))
-all: $(addprefix $(kapi)/,$(kapisyshdr-y))
+all: $(uapisyshdr-y) $(kapisyshdr-y)
 	@:
diff --git a/arch/ia64/kernel/syscalls/Makefile b/arch/ia64/kernel/syscalls/Makefile
index 813a58cba39c..b9bfd186295f 100644
--- a/arch/ia64/kernel/syscalls/Makefile
+++ b/arch/ia64/kernel/syscalls/Makefile
@@ -22,19 +22,20 @@ quiet_cmd_systbl = SYSTBL  $@
 		   '$(systbl_offset_$(basetarget))'
 
 syshdr_offset_unistd_64 := __NR_Linux
-$(uapi)/unistd_64.h: $(syscall) $(syshdr)
+$(uapi)/unistd_64.h: $(syscall) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
 systbl_offset_syscall_table := 1024
-$(kapi)/syscall_table.h: $(syscall) $(systbl)
+$(kapi)/syscall_table.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 uapisyshdr-y		+= unistd_64.h
 kapisyshdr-y		+= syscall_table.h
 
-targets	+= $(uapisyshdr-y) $(kapisyshdr-y)
+uapisyshdr-y	:= $(addprefix $(uapi)/, $(uapisyshdr-y))
+kapisyshdr-y	:= $(addprefix $(kapi)/, $(kapisyshdr-y))
+targets		+= $(addprefix ../../../../, $(uapisyshdr-y) $(kapisyshdr-y))
 
 PHONY += all
-all: $(addprefix $(uapi)/,$(uapisyshdr-y))
-all: $(addprefix $(kapi)/,$(kapisyshdr-y))
+all: $(uapisyshdr-y) $(kapisyshdr-y)
 	@:
diff --git a/arch/m68k/kernel/syscalls/Makefile b/arch/m68k/kernel/syscalls/Makefile
index 659faefdcb1d..1c42d2d2926d 100644
--- a/arch/m68k/kernel/syscalls/Makefile
+++ b/arch/m68k/kernel/syscalls/Makefile
@@ -21,18 +21,19 @@ quiet_cmd_systbl = SYSTBL  $@
 		   '$(systbl_abi_$(basetarget))'		\
 		   '$(systbl_offset_$(basetarget))'
 
-$(uapi)/unistd_32.h: $(syscall) $(syshdr)
+$(uapi)/unistd_32.h: $(syscall) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
-$(kapi)/syscall_table.h: $(syscall) $(systbl)
+$(kapi)/syscall_table.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 uapisyshdr-y		+= unistd_32.h
 kapisyshdr-y		+= syscall_table.h
 
-targets	+= $(uapisyshdr-y) $(kapisyshdr-y)
+uapisyshdr-y	:= $(addprefix $(uapi)/, $(uapisyshdr-y))
+kapisyshdr-y	:= $(addprefix $(kapi)/, $(kapisyshdr-y))
+targets		+= $(addprefix ../../../../, $(uapisyshdr-y) $(kapisyshdr-y))
 
 PHONY += all
-all: $(addprefix $(uapi)/,$(uapisyshdr-y))
-all: $(addprefix $(kapi)/,$(kapisyshdr-y))
+all: $(uapisyshdr-y) $(kapisyshdr-y)
 	@:
diff --git a/arch/microblaze/kernel/syscalls/Makefile b/arch/microblaze/kernel/syscalls/Makefile
index 659faefdcb1d..1c42d2d2926d 100644
--- a/arch/microblaze/kernel/syscalls/Makefile
+++ b/arch/microblaze/kernel/syscalls/Makefile
@@ -21,18 +21,19 @@ quiet_cmd_systbl = SYSTBL  $@
 		   '$(systbl_abi_$(basetarget))'		\
 		   '$(systbl_offset_$(basetarget))'
 
-$(uapi)/unistd_32.h: $(syscall) $(syshdr)
+$(uapi)/unistd_32.h: $(syscall) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
-$(kapi)/syscall_table.h: $(syscall) $(systbl)
+$(kapi)/syscall_table.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 uapisyshdr-y		+= unistd_32.h
 kapisyshdr-y		+= syscall_table.h
 
-targets	+= $(uapisyshdr-y) $(kapisyshdr-y)
+uapisyshdr-y	:= $(addprefix $(uapi)/, $(uapisyshdr-y))
+kapisyshdr-y	:= $(addprefix $(kapi)/, $(kapisyshdr-y))
+targets		+= $(addprefix ../../../../, $(uapisyshdr-y) $(kapisyshdr-y))
 
 PHONY += all
-all: $(addprefix $(uapi)/,$(uapisyshdr-y))
-all: $(addprefix $(kapi)/,$(kapisyshdr-y))
+all: $(uapisyshdr-y) $(kapisyshdr-y)
 	@:
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
diff --git a/arch/parisc/kernel/syscalls/Makefile b/arch/parisc/kernel/syscalls/Makefile
index c22a21c39f30..556fe30a6c8f 100644
--- a/arch/parisc/kernel/syscalls/Makefile
+++ b/arch/parisc/kernel/syscalls/Makefile
@@ -22,24 +22,24 @@ quiet_cmd_systbl = SYSTBL  $@
 		   '$(systbl_offset_$(basetarget))'
 
 syshdr_abis_unistd_32 := common,32
-$(uapi)/unistd_32.h: $(syscall) $(syshdr)
+$(uapi)/unistd_32.h: $(syscall) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
 syshdr_abis_unistd_64 := common,64
-$(uapi)/unistd_64.h: $(syscall) $(syshdr)
+$(uapi)/unistd_64.h: $(syscall) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
 systbl_abis_syscall_table_32 := common,32
-$(kapi)/syscall_table_32.h: $(syscall) $(systbl)
+$(kapi)/syscall_table_32.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 systbl_abis_syscall_table_64 := common,64
-$(kapi)/syscall_table_64.h: $(syscall) $(systbl)
+$(kapi)/syscall_table_64.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 systbl_abis_syscall_table_c32 := common,32
 systbl_abi_syscall_table_c32 := c32
-$(kapi)/syscall_table_c32.h: $(syscall) $(systbl)
+$(kapi)/syscall_table_c32.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 uapisyshdr-y		+= unistd_32.h unistd_64.h
@@ -47,9 +47,10 @@ kapisyshdr-y		+= syscall_table_32.h		\
 			   syscall_table_64.h		\
 			   syscall_table_c32.h
 
-targets	+= $(uapisyshdr-y) $(kapisyshdr-y)
+uapisyshdr-y	:= $(addprefix $(uapi)/, $(uapisyshdr-y))
+kapisyshdr-y	:= $(addprefix $(kapi)/, $(kapisyshdr-y))
+targets		+= $(addprefix ../../../../, $(uapisyshdr-y) $(kapisyshdr-y))
 
 PHONY += all
-all: $(addprefix $(uapi)/,$(uapisyshdr-y))
-all: $(addprefix $(kapi)/,$(kapisyshdr-y))
+all: $(uapisyshdr-y) $(kapisyshdr-y)
 	@:
diff --git a/arch/powerpc/kernel/syscalls/Makefile b/arch/powerpc/kernel/syscalls/Makefile
index 27b48954808d..d609f0040b2a 100644
--- a/arch/powerpc/kernel/syscalls/Makefile
+++ b/arch/powerpc/kernel/syscalls/Makefile
@@ -22,31 +22,31 @@ quiet_cmd_systbl = SYSTBL  $@
 		   '$(systbl_offset_$(basetarget))'
 
 syshdr_abis_unistd_32 := common,nospu,32
-$(uapi)/unistd_32.h: $(syscall) $(syshdr)
+$(uapi)/unistd_32.h: $(syscall) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
 syshdr_abis_unistd_64 := common,nospu,64
-$(uapi)/unistd_64.h: $(syscall) $(syshdr)
+$(uapi)/unistd_64.h: $(syscall) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
 systbl_abis_syscall_table_32 := common,nospu,32
 systbl_abi_syscall_table_32 := 32
-$(kapi)/syscall_table_32.h: $(syscall) $(systbl)
+$(kapi)/syscall_table_32.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 systbl_abis_syscall_table_64 := common,nospu,64
 systbl_abi_syscall_table_64 := 64
-$(kapi)/syscall_table_64.h: $(syscall) $(systbl)
+$(kapi)/syscall_table_64.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 systbl_abis_syscall_table_c32 := common,nospu,32
 systbl_abi_syscall_table_c32 := c32
-$(kapi)/syscall_table_c32.h: $(syscall) $(systbl)
+$(kapi)/syscall_table_c32.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 systbl_abis_syscall_table_spu := common,spu
 systbl_abi_syscall_table_spu := spu
-$(kapi)/syscall_table_spu.h: $(syscall) $(systbl)
+$(kapi)/syscall_table_spu.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 uapisyshdr-y		+= unistd_32.h unistd_64.h
@@ -55,9 +55,10 @@ kapisyshdr-y		+= syscall_table_32.h		\
 			   syscall_table_c32.h		\
 			   syscall_table_spu.h
 
-targets	+= $(uapisyshdr-y) $(kapisyshdr-y)
+uapisyshdr-y	:= $(addprefix $(uapi)/, $(uapisyshdr-y))
+kapisyshdr-y	:= $(addprefix $(kapi)/, $(kapisyshdr-y))
+targets		+= $(addprefix ../../../../, $(uapisyshdr-y) $(kapisyshdr-y))
 
 PHONY += all
-all: $(addprefix $(uapi)/,$(uapisyshdr-y))
-all: $(addprefix $(kapi)/,$(kapisyshdr-y))
+all: $(uapisyshdr-y) $(kapisyshdr-y)
 	@:
diff --git a/arch/sh/kernel/syscalls/Makefile b/arch/sh/kernel/syscalls/Makefile
index 659faefdcb1d..1c42d2d2926d 100644
--- a/arch/sh/kernel/syscalls/Makefile
+++ b/arch/sh/kernel/syscalls/Makefile
@@ -21,18 +21,19 @@ quiet_cmd_systbl = SYSTBL  $@
 		   '$(systbl_abi_$(basetarget))'		\
 		   '$(systbl_offset_$(basetarget))'
 
-$(uapi)/unistd_32.h: $(syscall) $(syshdr)
+$(uapi)/unistd_32.h: $(syscall) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
-$(kapi)/syscall_table.h: $(syscall) $(systbl)
+$(kapi)/syscall_table.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 uapisyshdr-y		+= unistd_32.h
 kapisyshdr-y		+= syscall_table.h
 
-targets	+= $(uapisyshdr-y) $(kapisyshdr-y)
+uapisyshdr-y	:= $(addprefix $(uapi)/, $(uapisyshdr-y))
+kapisyshdr-y	:= $(addprefix $(kapi)/, $(kapisyshdr-y))
+targets		+= $(addprefix ../../../../, $(uapisyshdr-y) $(kapisyshdr-y))
 
 PHONY += all
-all: $(addprefix $(uapi)/,$(uapisyshdr-y))
-all: $(addprefix $(kapi)/,$(kapisyshdr-y))
+all: $(uapisyshdr-y) $(kapisyshdr-y)
 	@:
diff --git a/arch/sparc/kernel/syscalls/Makefile b/arch/sparc/kernel/syscalls/Makefile
index c22a21c39f30..556fe30a6c8f 100644
--- a/arch/sparc/kernel/syscalls/Makefile
+++ b/arch/sparc/kernel/syscalls/Makefile
@@ -22,24 +22,24 @@ quiet_cmd_systbl = SYSTBL  $@
 		   '$(systbl_offset_$(basetarget))'
 
 syshdr_abis_unistd_32 := common,32
-$(uapi)/unistd_32.h: $(syscall) $(syshdr)
+$(uapi)/unistd_32.h: $(syscall) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
 syshdr_abis_unistd_64 := common,64
-$(uapi)/unistd_64.h: $(syscall) $(syshdr)
+$(uapi)/unistd_64.h: $(syscall) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
 systbl_abis_syscall_table_32 := common,32
-$(kapi)/syscall_table_32.h: $(syscall) $(systbl)
+$(kapi)/syscall_table_32.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 systbl_abis_syscall_table_64 := common,64
-$(kapi)/syscall_table_64.h: $(syscall) $(systbl)
+$(kapi)/syscall_table_64.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 systbl_abis_syscall_table_c32 := common,32
 systbl_abi_syscall_table_c32 := c32
-$(kapi)/syscall_table_c32.h: $(syscall) $(systbl)
+$(kapi)/syscall_table_c32.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 uapisyshdr-y		+= unistd_32.h unistd_64.h
@@ -47,9 +47,10 @@ kapisyshdr-y		+= syscall_table_32.h		\
 			   syscall_table_64.h		\
 			   syscall_table_c32.h
 
-targets	+= $(uapisyshdr-y) $(kapisyshdr-y)
+uapisyshdr-y	:= $(addprefix $(uapi)/, $(uapisyshdr-y))
+kapisyshdr-y	:= $(addprefix $(kapi)/, $(kapisyshdr-y))
+targets		+= $(addprefix ../../../../, $(uapisyshdr-y) $(kapisyshdr-y))
 
 PHONY += all
-all: $(addprefix $(uapi)/,$(uapisyshdr-y))
-all: $(addprefix $(kapi)/,$(kapisyshdr-y))
+all: $(uapisyshdr-y) $(kapisyshdr-y)
 	@:
diff --git a/arch/x86/entry/syscalls/Makefile b/arch/x86/entry/syscalls/Makefile
index 6fb9b57ed5ba..e1c7ddb7546b 100644
--- a/arch/x86/entry/syscalls/Makefile
+++ b/arch/x86/entry/syscalls/Makefile
@@ -24,34 +24,34 @@ quiet_cmd_hypercalls = HYPERCALLS $@
       cmd_hypercalls = $(CONFIG_SHELL) '$<' $@ $(filter-out $<,$^)
 
 syshdr_abi_unistd_32 := i386
-$(uapi)/unistd_32.h: $(syscall32) $(syshdr)
+$(uapi)/unistd_32.h: $(syscall32) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
 syshdr_abi_unistd_32_ia32 := i386
 syshdr_pfx_unistd_32_ia32 := ia32_
-$(out)/unistd_32_ia32.h: $(syscall32) $(syshdr)
+$(out)/unistd_32_ia32.h: $(syscall32) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
 syshdr_abi_unistd_x32 := common,x32
 syshdr_offset_unistd_x32 := __X32_SYSCALL_BIT
-$(uapi)/unistd_x32.h: $(syscall64) $(syshdr)
+$(uapi)/unistd_x32.h: $(syscall64) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
 syshdr_abi_unistd_64 := common,64
-$(uapi)/unistd_64.h: $(syscall64) $(syshdr)
+$(uapi)/unistd_64.h: $(syscall64) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
 syshdr_abi_unistd_64_x32 := x32
 syshdr_pfx_unistd_64_x32 := x32_
-$(out)/unistd_64_x32.h: $(syscall64) $(syshdr)
+$(out)/unistd_64_x32.h: $(syscall64) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
-$(out)/syscalls_32.h: $(syscall32) $(systbl)
+$(out)/syscalls_32.h: $(syscall32) $(systbl) FORCE
 	$(call if_changed,systbl)
-$(out)/syscalls_64.h: $(syscall64) $(systbl)
+$(out)/syscalls_64.h: $(syscall64) $(systbl) FORCE
 	$(call if_changed,systbl)
 
-$(out)/xen-hypercalls.h: $(srctree)/scripts/xen-hypercalls.sh
+$(out)/xen-hypercalls.h: $(srctree)/scripts/xen-hypercalls.sh FORCE
 	$(call if_changed,hypercalls)
 
 $(out)/xen-hypercalls.h: $(srctree)/include/xen/interface/xen*.h
@@ -62,9 +62,10 @@ syshdr-$(CONFIG_X86_64)		+= unistd_32_ia32.h unistd_64_x32.h
 syshdr-$(CONFIG_X86_64)		+= syscalls_64.h
 syshdr-$(CONFIG_XEN)		+= xen-hypercalls.h
 
-targets	+= $(uapisyshdr-y) $(syshdr-y)
+uapisyshdr-y	:= $(addprefix $(uapi)/, $(uapisyshdr-y))
+syshdr-y	:= $(addprefix $(out)/, $(syshdr-y))
+targets		+= $(addprefix ../../../../, $(uapisyshdr-y) $(syshdr-y))
 
 PHONY += all
-all: $(addprefix $(uapi)/,$(uapisyshdr-y))
-all: $(addprefix $(out)/,$(syshdr-y))
+all: $(uapisyshdr-y) $(syshdr-y)
 	@:
diff --git a/arch/xtensa/kernel/syscalls/Makefile b/arch/xtensa/kernel/syscalls/Makefile
index 659faefdcb1d..1c42d2d2926d 100644
--- a/arch/xtensa/kernel/syscalls/Makefile
+++ b/arch/xtensa/kernel/syscalls/Makefile
@@ -21,18 +21,19 @@ quiet_cmd_systbl = SYSTBL  $@
 		   '$(systbl_abi_$(basetarget))'		\
 		   '$(systbl_offset_$(basetarget))'
 
-$(uapi)/unistd_32.h: $(syscall) $(syshdr)
+$(uapi)/unistd_32.h: $(syscall) $(syshdr) FORCE
 	$(call if_changed,syshdr)
 
-$(kapi)/syscall_table.h: $(syscall) $(systbl)
+$(kapi)/syscall_table.h: $(syscall) $(systbl) FORCE
 	$(call if_changed,systbl)
 
 uapisyshdr-y		+= unistd_32.h
 kapisyshdr-y		+= syscall_table.h
 
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
