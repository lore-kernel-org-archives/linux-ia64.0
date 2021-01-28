From: Masahiro Yamada <masahiroy@kernel.org>
Date: Thu, 28 Jan 2021 00:50:45 +0000
Subject: [PATCH 03/27] x86/build: add missing FORCE and fix 'targets' to make if_changed work
Message-Id: <20210128005110.2613902-4-masahiroy@kernel.org>
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

 arch/x86/entry/syscalls/Makefile | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

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
-- 
2.27.0
