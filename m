From: Masahiro Yamada <masahiroy@kernel.org>
Date: Mon, 15 Feb 2021 00:48:23 +0000
Subject: [PATCH 2/2] arch: syscalls: remove $(srctree)/ prefix from syscall tables
Message-Id: <20210215004823.440102-2-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210215004823.440102-1-masahiroy@kernel.org>
In-Reply-To: <20210215004823.440102-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: Masahiro Yamada <masahiroy@kernel.org>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Borislav Petkov <bp@alien8.de>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "H. Peter Anvin" <hpa@zytor.com>, Helge Deller <deller@gmx.de>, Ingo Molnar <mingo@redhat.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Richard Henderson <rth@twiddle.net>, Russell King <linux@armlinux.org.uk>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, x86@kernel.org

The 'syscall' variables are not directly used in the commands.
Remove the $(srctree)/ prefix because we can rely on VPATH.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

 arch/alpha/kernel/syscalls/Makefile      | 2 +-
 arch/arm/tools/Makefile                  | 2 +-
 arch/ia64/kernel/syscalls/Makefile       | 2 +-
 arch/m68k/kernel/syscalls/Makefile       | 2 +-
 arch/microblaze/kernel/syscalls/Makefile | 2 +-
 arch/mips/kernel/syscalls/Makefile       | 6 +++---
 arch/parisc/kernel/syscalls/Makefile     | 2 +-
 arch/powerpc/kernel/syscalls/Makefile    | 2 +-
 arch/sh/kernel/syscalls/Makefile         | 2 +-
 arch/sparc/kernel/syscalls/Makefile      | 2 +-
 arch/x86/entry/syscalls/Makefile         | 4 ++--
 arch/xtensa/kernel/syscalls/Makefile     | 2 +-
 12 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/arch/alpha/kernel/syscalls/Makefile b/arch/alpha/kernel/syscalls/Makefile
index 1c42d2d2926d..285aaba832d9 100644
--- a/arch/alpha/kernel/syscalls/Makefile
+++ b/arch/alpha/kernel/syscalls/Makefile
@@ -5,7 +5,7 @@ uapi := arch/$(SRCARCH)/include/generated/uapi/asm
 _dummy := $(shell [ -d '$(uapi)' ] || mkdir -p '$(uapi)')	\
 	  $(shell [ -d '$(kapi)' ] || mkdir -p '$(kapi)')
 
-syscall := $(srctree)/$(src)/syscall.tbl
+syscall := $(src)/syscall.tbl
 syshdr := $(srctree)/$(src)/syscallhdr.sh
 systbl := $(srctree)/$(src)/syscalltbl.sh
 
diff --git a/arch/arm/tools/Makefile b/arch/arm/tools/Makefile
index 27d8beb7c941..3654f979851b 100644
--- a/arch/arm/tools/Makefile
+++ b/arch/arm/tools/Makefile
@@ -11,7 +11,7 @@ uapi := $(gen)/uapi/asm
 syshdr := $(srctree)/$(src)/syscallhdr.sh
 sysnr := $(srctree)/$(src)/syscallnr.sh
 systbl := $(srctree)/$(src)/syscalltbl.sh
-syscall := $(srctree)/$(src)/syscall.tbl
+syscall := $(src)/syscall.tbl
 
 gen-y := $(gen)/calls-oabi.S
 gen-y += $(gen)/calls-eabi.S
diff --git a/arch/ia64/kernel/syscalls/Makefile b/arch/ia64/kernel/syscalls/Makefile
index b9bfd186295f..bf4bda0f63eb 100644
--- a/arch/ia64/kernel/syscalls/Makefile
+++ b/arch/ia64/kernel/syscalls/Makefile
@@ -5,7 +5,7 @@ uapi := arch/$(SRCARCH)/include/generated/uapi/asm
 _dummy := $(shell [ -d '$(uapi)' ] || mkdir -p '$(uapi)')	\
 	  $(shell [ -d '$(kapi)' ] || mkdir -p '$(kapi)')
 
-syscall := $(srctree)/$(src)/syscall.tbl
+syscall := $(src)/syscall.tbl
 syshdr := $(srctree)/$(src)/syscallhdr.sh
 systbl := $(srctree)/$(src)/syscalltbl.sh
 
diff --git a/arch/m68k/kernel/syscalls/Makefile b/arch/m68k/kernel/syscalls/Makefile
index 1c42d2d2926d..285aaba832d9 100644
--- a/arch/m68k/kernel/syscalls/Makefile
+++ b/arch/m68k/kernel/syscalls/Makefile
@@ -5,7 +5,7 @@ uapi := arch/$(SRCARCH)/include/generated/uapi/asm
 _dummy := $(shell [ -d '$(uapi)' ] || mkdir -p '$(uapi)')	\
 	  $(shell [ -d '$(kapi)' ] || mkdir -p '$(kapi)')
 
-syscall := $(srctree)/$(src)/syscall.tbl
+syscall := $(src)/syscall.tbl
 syshdr := $(srctree)/$(src)/syscallhdr.sh
 systbl := $(srctree)/$(src)/syscalltbl.sh
 
diff --git a/arch/microblaze/kernel/syscalls/Makefile b/arch/microblaze/kernel/syscalls/Makefile
index 1c42d2d2926d..285aaba832d9 100644
--- a/arch/microblaze/kernel/syscalls/Makefile
+++ b/arch/microblaze/kernel/syscalls/Makefile
@@ -5,7 +5,7 @@ uapi := arch/$(SRCARCH)/include/generated/uapi/asm
 _dummy := $(shell [ -d '$(uapi)' ] || mkdir -p '$(uapi)')	\
 	  $(shell [ -d '$(kapi)' ] || mkdir -p '$(kapi)')
 
-syscall := $(srctree)/$(src)/syscall.tbl
+syscall := $(src)/syscall.tbl
 syshdr := $(srctree)/$(src)/syscallhdr.sh
 systbl := $(srctree)/$(src)/syscalltbl.sh
 
diff --git a/arch/mips/kernel/syscalls/Makefile b/arch/mips/kernel/syscalls/Makefile
index f15842bda464..ed22b711ccb7 100644
--- a/arch/mips/kernel/syscalls/Makefile
+++ b/arch/mips/kernel/syscalls/Makefile
@@ -5,9 +5,9 @@ uapi := arch/$(SRCARCH)/include/generated/uapi/asm
 _dummy := $(shell [ -d '$(uapi)' ] || mkdir -p '$(uapi)')	\
 	  $(shell [ -d '$(kapi)' ] || mkdir -p '$(kapi)')
 
-syscalln32 := $(srctree)/$(src)/syscall_n32.tbl
-syscalln64 := $(srctree)/$(src)/syscall_n64.tbl
-syscallo32 := $(srctree)/$(src)/syscall_o32.tbl
+syscalln32 := $(src)/syscall_n32.tbl
+syscalln64 := $(src)/syscall_n64.tbl
+syscallo32 := $(src)/syscall_o32.tbl
 syshdr := $(srctree)/$(src)/syscallhdr.sh
 sysnr := $(srctree)/$(src)/syscallnr.sh
 systbl := $(srctree)/$(src)/syscalltbl.sh
diff --git a/arch/parisc/kernel/syscalls/Makefile b/arch/parisc/kernel/syscalls/Makefile
index 556fe30a6c8f..283f64407b07 100644
--- a/arch/parisc/kernel/syscalls/Makefile
+++ b/arch/parisc/kernel/syscalls/Makefile
@@ -5,7 +5,7 @@ uapi := arch/$(SRCARCH)/include/generated/uapi/asm
 _dummy := $(shell [ -d '$(uapi)' ] || mkdir -p '$(uapi)')	\
 	  $(shell [ -d '$(kapi)' ] || mkdir -p '$(kapi)')
 
-syscall := $(srctree)/$(src)/syscall.tbl
+syscall := $(src)/syscall.tbl
 syshdr := $(srctree)/$(src)/syscallhdr.sh
 systbl := $(srctree)/$(src)/syscalltbl.sh
 
diff --git a/arch/powerpc/kernel/syscalls/Makefile b/arch/powerpc/kernel/syscalls/Makefile
index d609f0040b2a..9e3be295dbba 100644
--- a/arch/powerpc/kernel/syscalls/Makefile
+++ b/arch/powerpc/kernel/syscalls/Makefile
@@ -5,7 +5,7 @@ uapi := arch/$(SRCARCH)/include/generated/uapi/asm
 _dummy := $(shell [ -d '$(uapi)' ] || mkdir -p '$(uapi)')	\
 	  $(shell [ -d '$(kapi)' ] || mkdir -p '$(kapi)')
 
-syscall := $(srctree)/$(src)/syscall.tbl
+syscall := $(src)/syscall.tbl
 syshdr := $(srctree)/$(src)/syscallhdr.sh
 systbl := $(srctree)/$(src)/syscalltbl.sh
 
diff --git a/arch/sh/kernel/syscalls/Makefile b/arch/sh/kernel/syscalls/Makefile
index 1c42d2d2926d..285aaba832d9 100644
--- a/arch/sh/kernel/syscalls/Makefile
+++ b/arch/sh/kernel/syscalls/Makefile
@@ -5,7 +5,7 @@ uapi := arch/$(SRCARCH)/include/generated/uapi/asm
 _dummy := $(shell [ -d '$(uapi)' ] || mkdir -p '$(uapi)')	\
 	  $(shell [ -d '$(kapi)' ] || mkdir -p '$(kapi)')
 
-syscall := $(srctree)/$(src)/syscall.tbl
+syscall := $(src)/syscall.tbl
 syshdr := $(srctree)/$(src)/syscallhdr.sh
 systbl := $(srctree)/$(src)/syscalltbl.sh
 
diff --git a/arch/sparc/kernel/syscalls/Makefile b/arch/sparc/kernel/syscalls/Makefile
index 556fe30a6c8f..283f64407b07 100644
--- a/arch/sparc/kernel/syscalls/Makefile
+++ b/arch/sparc/kernel/syscalls/Makefile
@@ -5,7 +5,7 @@ uapi := arch/$(SRCARCH)/include/generated/uapi/asm
 _dummy := $(shell [ -d '$(uapi)' ] || mkdir -p '$(uapi)')	\
 	  $(shell [ -d '$(kapi)' ] || mkdir -p '$(kapi)')
 
-syscall := $(srctree)/$(src)/syscall.tbl
+syscall := $(src)/syscall.tbl
 syshdr := $(srctree)/$(src)/syscallhdr.sh
 systbl := $(srctree)/$(src)/syscalltbl.sh
 
diff --git a/arch/x86/entry/syscalls/Makefile b/arch/x86/entry/syscalls/Makefile
index e1c7ddb7546b..cf388e9e8989 100644
--- a/arch/x86/entry/syscalls/Makefile
+++ b/arch/x86/entry/syscalls/Makefile
@@ -6,8 +6,8 @@ uapi := arch/$(SRCARCH)/include/generated/uapi/asm
 _dummy := $(shell [ -d '$(out)' ] || mkdir -p '$(out)') \
 	  $(shell [ -d '$(uapi)' ] || mkdir -p '$(uapi)')
 
-syscall32 := $(srctree)/$(src)/syscall_32.tbl
-syscall64 := $(srctree)/$(src)/syscall_64.tbl
+syscall32 := $(src)/syscall_32.tbl
+syscall64 := $(src)/syscall_64.tbl
 
 syshdr := $(srctree)/$(src)/syscallhdr.sh
 systbl := $(srctree)/$(src)/syscalltbl.sh
diff --git a/arch/xtensa/kernel/syscalls/Makefile b/arch/xtensa/kernel/syscalls/Makefile
index 1c42d2d2926d..285aaba832d9 100644
--- a/arch/xtensa/kernel/syscalls/Makefile
+++ b/arch/xtensa/kernel/syscalls/Makefile
@@ -5,7 +5,7 @@ uapi := arch/$(SRCARCH)/include/generated/uapi/asm
 _dummy := $(shell [ -d '$(uapi)' ] || mkdir -p '$(uapi)')	\
 	  $(shell [ -d '$(kapi)' ] || mkdir -p '$(kapi)')
 
-syscall := $(srctree)/$(src)/syscall.tbl
+syscall := $(src)/syscall.tbl
 syshdr := $(srctree)/$(src)/syscallhdr.sh
 systbl := $(srctree)/$(src)/syscalltbl.sh
 
-- 
2.27.0
