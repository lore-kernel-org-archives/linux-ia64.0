From: AKASHI Takahiro <takahiro.akashi@linaro.org>
Date: Tue, 25 Feb 2014 09:16:24 +0000
Subject: [PATCH v2 1/1] audit: Add CONFIG_HAVE_ARCH_AUDITSYSCALL
Message-Id: <1393319784-2758-2-git-send-email-takahiro.akashi@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1391407232-4623-1-git-send-email-takahiro.akashi@linaro.org>
 <1393319784-2758-1-git-send-email-takahiro.akashi@linaro.org>
In-Reply-To: <1393319784-2758-1-git-send-email-takahiro.akashi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Currently AUDITSYSCALL has a long list of architecture depencency:
       depends on AUDIT && (X86 || PARISC || PPC || S390 || IA64 || UML ||
		SPARC64 || SUPERH || (ARM && AEABI && !OABI_COMPAT) || ALPHA)
The purpose of this patch is to replace it with HAVE_ARCH_AUDITSYSCALL
for simplicity.

Signed-off-by: AKASHI Takahiro <takahiro.akashi@linaro.org>
---
 arch/alpha/Kconfig     |    1 +
 arch/arm/Kconfig       |    1 +
 arch/ia64/Kconfig      |    1 +
 arch/parisc/Kconfig    |    1 +
 arch/powerpc/Kconfig   |    1 +
 arch/s390/Kconfig      |    1 +
 arch/sh/Kconfig        |    1 +
 arch/sparc/Kconfig     |    1 +
 arch/um/Kconfig.common |    1 +
 arch/x86/Kconfig       |    1 +
 init/Kconfig           |    5 ++++-
 11 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index f6c6b34..b7ff9a3 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -22,6 +22,7 @@ config ALPHA
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_STRNCPY_FROM_USER
 	select GENERIC_STRNLEN_USER
+	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
 	select ODD_RT_SIGACTION
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index e254198..ca79340 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -24,6 +24,7 @@ config ARM
 	select GENERIC_STRNCPY_FROM_USER
 	select GENERIC_STRNLEN_USER
 	select HARDIRQS_SW_RESEND
+	select HAVE_ARCH_AUDITSYSCALL if (AEABI && !OABI_COMPAT)
 	select HAVE_ARCH_JUMP_LABEL if !XIP_KERNEL
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_SECCOMP_FILTER if (AEABI && !OABI_COMPAT)
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 0c8e553..5409bf4 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -44,6 +44,7 @@ config IA64
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
 	select ARCH_USE_CMPXCHG_LOCKREF
+	select HAVE_ARCH_AUDITSYSCALL
 	default y
 	help
 	  The Itanium Processor Family is Intel's 64-bit successor to
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index bb2a8ec..1faefed 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -28,6 +28,7 @@ config PARISC
 	select CLONE_BACKWARDS
 	select TTY # Needed for pdc_cons.c
 	select HAVE_DEBUG_STACKOVERFLOW
+	select HAVE_ARCH_AUDITSYSCALL
 
 	help
 	  The PA-RISC microprocessor is designed by Hewlett-Packard and used
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 957bf34..7b3b8fe 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -141,6 +141,7 @@ config PPC
 	select HAVE_DEBUG_STACKOVERFLOW
 	select HAVE_IRQ_EXIT_ON_IRQ_STACK
 	select ARCH_USE_CMPXCHG_LOCKREF if PPC64
+	select HAVE_ARCH_AUDITSYSCALL
 
 config GENERIC_CSUM
 	def_bool CPU_LITTLE_ENDIAN
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 65a0775..1b58568 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -103,6 +103,7 @@ config S390
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_TIME_VSYSCALL
 	select HAVE_ALIGNED_STRUCT_PAGE if SLUB
+	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_JUMP_LABEL if !MARCH_G5
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index 6357710..4addd87 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -42,6 +42,7 @@ config SUPERH
 	select MODULES_USE_ELF_RELA
 	select OLD_SIGSUSPEND
 	select OLD_SIGACTION
+	select HAVE_ARCH_AUDITSYSCALL
 	help
 	  The SuperH is a RISC processor targeted for use in embedded systems
 	  and consumer electronics; it was also used in the Sega Dreamcast
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index c51efdc..9c74d6b 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -77,6 +77,7 @@ config SPARC64
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select HAVE_C_RECORDMCOUNT
 	select NO_BOOTMEM
+	select HAVE_ARCH_AUDITSYSCALL
 
 config ARCH_DEFCONFIG
 	string
diff --git a/arch/um/Kconfig.common b/arch/um/Kconfig.common
index 21ca44c..6915d28 100644
--- a/arch/um/Kconfig.common
+++ b/arch/um/Kconfig.common
@@ -1,6 +1,7 @@
 config UML
 	bool
 	default y
+	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_UID16
 	select GENERIC_IRQ_SHOW
 	select GENERIC_CPU_DEVICES
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 0af5250..2938365 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -127,6 +127,7 @@ config X86
 	select HAVE_DEBUG_STACKOVERFLOW
 	select HAVE_IRQ_EXIT_ON_IRQ_STACK if X86_64
 	select HAVE_CC_STACKPROTECTOR
+	select HAVE_ARCH_AUDITSYSCALL
 
 config INSTRUCTION_DECODER
 	def_bool y
diff --git a/init/Kconfig b/init/Kconfig
index 009a797..d4ec53d 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -282,9 +282,12 @@ config AUDIT
 	  logging of avc messages output).  Does not do system-call
 	  auditing without CONFIG_AUDITSYSCALL.
 
+config HAVE_ARCH_AUDITSYSCALL
+	bool
+
 config AUDITSYSCALL
 	bool "Enable system-call auditing support"
-	depends on AUDIT && (X86 || PARISC || PPC || S390 || IA64 || UML || SPARC64 || SUPERH || (ARM && AEABI && !OABI_COMPAT) || ALPHA)
+	depends on AUDIT && HAVE_ARCH_AUDITSYSCALL
 	default y if SECURITY_SELINUX
 	help
 	  Enable low-overhead system-call auditing infrastructure that
-- 
1.7.9.5

