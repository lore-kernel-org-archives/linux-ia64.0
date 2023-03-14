From: Niklas Schnelle <schnelle@linux.ibm.com>
Date: Tue, 14 Mar 2023 12:11:39 +0000
Subject: [PATCH v3 01/38] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <20230314121216.413434-2-schnelle@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230314121216.413434-1-schnelle@linux.ibm.com>
In-Reply-To: <20230314121216.413434-1-schnelle@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S. Miller" <davem@davemloft.net>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Bjorn Helgaas <bhelgaas@google.com>, =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, Alan Stern <stern@rowland.harvard.edu>, "Rafael J. Wysocki" <rafael@kernel.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-pci@vger.kernel.org, Arnd Bergmann <arnd@kernel.org>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org

We introduce a new HAS_IOPORT Kconfig option to indicate support for I/O
Port access. In a future patch HAS_IOPORT=n will disable compilation of
the I/O accessor functions inb()/outb() and friends on architectures
which can not meaningfully support legacy I/O spaces such as s390. Also
add dependencies on HAS_IOPORT for the ISA and HAVE_EISA config options
as these busses always go along with HAS_IOPORT.

The "depends on" relations on HAS_IOPORT in drivers as well as ifdefs
for HAS_IOPORT specific sections will be added in subsequent patches on
a per subsystem basis.

Co-developed-by: Arnd Bergmann <arnd@kernel.org>
Signed-off-by: Niklas Schnelle <schnelle@linux.ibm.com>
---
 arch/alpha/Kconfig      | 1 +
 arch/arm/Kconfig        | 1 +
 arch/arm64/Kconfig      | 1 +
 arch/ia64/Kconfig       | 1 +
 arch/m68k/Kconfig       | 1 +
 arch/microblaze/Kconfig | 1 +
 arch/mips/Kconfig       | 2 ++
 arch/parisc/Kconfig     | 2 ++
 arch/powerpc/Kconfig    | 2 +-
 arch/riscv/Kconfig      | 1 +
 arch/sh/Kconfig         | 1 +
 arch/sparc/Kconfig      | 1 +
 arch/um/Kconfig         | 1 +
 arch/x86/Kconfig        | 2 ++
 drivers/bus/Kconfig     | 2 +-
 drivers/eisa/Kconfig    | 1 +
 lib/Kconfig             | 4 ++++
 lib/Kconfig.kgdb        | 3 ++-
 18 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index 780d4673c3ca..a5c2b1aa46b0 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -27,6 +27,7 @@ config ALPHA
 	select AUDIT_ARCH
 	select GENERIC_CPU_VULNERABILITIES
 	select GENERIC_SMP_IDLE_THREAD
+	select HAS_IOPORT
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index e24a9820e12f..4acb5bc4b52a 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -70,6 +70,7 @@ config ARM
 	select GENERIC_SCHED_CLOCK
 	select GENERIC_SMP_IDLE_THREAD
 	select HARDIRQS_SW_RESEND
+	select HAS_IOPORT
 	select HAVE_ARCH_AUDITSYSCALL if AEABI && !OABI_COMPAT
 	select HAVE_ARCH_BITREVERSE if (CPU_32v7M || CPU_32v7) && !CPU_32v6
 	select HAVE_ARCH_JUMP_LABEL if !XIP_KERNEL && !CPU_ENDIAN_BE32 && MMU
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 1023e896d46b..b740019c4aee 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -145,6 +145,7 @@ config ARM64
 	select GENERIC_GETTIMEOFDAY
 	select GENERIC_VDSO_TIME_NS
 	select HARDIRQS_SW_RESEND
+	select HAS_IOPORT
 	select HAVE_MOVE_PMD
 	select HAVE_MOVE_PUD
 	select HAVE_PCI
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index d7e4a24e8644..2e13ec8263b9 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -25,6 +25,7 @@ config IA64
 	select PCI_DOMAINS if PCI
 	select PCI_MSI
 	select PCI_SYSCALL if PCI
+	select HAS_IOPORT
 	select HAVE_ASM_MODVERSIONS
 	select HAVE_UNSTABLE_SCHED_CLOCK
 	select HAVE_EXIT_THREAD
diff --git a/arch/m68k/Kconfig b/arch/m68k/Kconfig
index 82154952e574..40198a1ebe27 100644
--- a/arch/m68k/Kconfig
+++ b/arch/m68k/Kconfig
@@ -18,6 +18,7 @@ config M68K
 	select GENERIC_CPU_DEVICES
 	select GENERIC_IOMAP
 	select GENERIC_IRQ_SHOW
+	select HAS_IOPORT if PCI || ISA || ATARI_ROM_ISA
 	select HAVE_ARCH_SECCOMP
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ASM_MODVERSIONS
diff --git a/arch/microblaze/Kconfig b/arch/microblaze/Kconfig
index cc88af6fa7a4..211f338d6235 100644
--- a/arch/microblaze/Kconfig
+++ b/arch/microblaze/Kconfig
@@ -21,6 +21,7 @@ config MICROBLAZE
 	select GENERIC_IRQ_SHOW
 	select GENERIC_PCI_IOMAP
 	select GENERIC_SCHED_CLOCK
+	select HAS_IOPORT if PCI
 	select HAVE_ARCH_HASH
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_SECCOMP
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index e2f3ca73f40d..64760fcd7b52 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -47,6 +47,7 @@ config MIPS
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_TIME_VSYSCALL
 	select GUP_GET_PXX_LOW_HIGH if CPU_MIPS32 && PHYS_ADDR_T_64BIT
+	select HAS_IOPORT if !NO_IOPORT_MAP
 	select HAVE_ARCH_COMPILER_H
 	select HAVE_ARCH_JUMP_LABEL
 	select HAVE_ARCH_KGDB if MIPS_FP_SUPPORT
@@ -3120,6 +3121,7 @@ config PCI_DRIVERS_LEGACY
 # users to choose the right thing ...
 #
 config ISA
+	depends on HAS_IOPORT
 	bool
 
 config TC
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index a98940e64243..5eeacc72e4da 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -47,6 +47,7 @@ config PARISC
 	select MODULES_USE_ELF_RELA
 	select CLONE_BACKWARDS
 	select TTY # Needed for pdc_cons.c
+	select HAS_IOPORT if PCI
 	select HAVE_DEBUG_STACKOVERFLOW
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_HASH
@@ -131,6 +132,7 @@ config STACKTRACE_SUPPORT
 
 config ISA_DMA_API
 	bool
+	depends on HAS_IOPORT
 
 config ARCH_MAY_HAVE_PC_FDC
 	bool
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index a6c4407d3ec8..f7de646c074a 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -188,6 +188,7 @@ config PPC
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_TIME_VSYSCALL
 	select GENERIC_VDSO_TIME_NS
+	select HAS_IOPORT			if PCI
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_HUGE_VMALLOC		if HAVE_ARCH_HUGE_VMAP
 	select HAVE_ARCH_HUGE_VMAP		if PPC_RADIX_MMU || PPC_8xx
@@ -1070,7 +1071,6 @@ menu "Bus options"
 
 config ISA
 	bool "Support for ISA-bus hardware"
-	depends on PPC_CHRP
 	select PPC_I8259
 	help
 	  Find out whether you have ISA slots on your motherboard.  ISA is the
diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index c5e42cc37604..b957d12a171b 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -74,6 +74,7 @@ config RISCV
 	select GENERIC_TIME_VSYSCALL if MMU && 64BIT
 	select GENERIC_VDSO_TIME_NS if HAVE_GENERIC_VDSO
 	select HARDIRQS_SW_RESEND
+	select HAS_IOPORT if MMU
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_HUGE_VMALLOC if HAVE_ARCH_HUGE_VMAP
 	select HAVE_ARCH_HUGE_VMAP if MMU && 64BIT && !XIP_KERNEL
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index 0665ac0add0b..cfb797bc4200 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -25,6 +25,7 @@ config SUPERH
 	select GENERIC_SCHED_CLOCK
 	select GENERIC_SMP_IDLE_THREAD
 	select GUP_GET_PXX_LOW_HIGH if X2TLB
+	select HAS_IOPORT if HAS_IOPORT_MAP
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_SECCOMP_FILTER
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 84437a4c6545..d4c1d96f85cd 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -32,6 +32,7 @@ config SPARC
 	select GENERIC_IRQ_SHOW
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select GENERIC_PCI_IOMAP
+	select HAS_IOPORT
 	select HAVE_NMI_WATCHDOG if SPARC64
 	select HAVE_CBPF_JIT if SPARC32
 	select HAVE_EBPF_JIT if SPARC64
diff --git a/arch/um/Kconfig b/arch/um/Kconfig
index 541a9b18e343..452d268be2e8 100644
--- a/arch/um/Kconfig
+++ b/arch/um/Kconfig
@@ -56,6 +56,7 @@ config NO_IOPORT_MAP
 
 config ISA
 	bool
+	depends on HAS_IOPORT
 
 config SBUS
 	bool
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index a825bf031f49..634dd42532f3 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -162,6 +162,7 @@ config X86
 	select GUP_GET_PXX_LOW_HIGH		if X86_PAE
 	select HARDIRQS_SW_RESEND
 	select HARDLOCKUP_CHECK_TIMESTAMP	if X86_64
+	select HAS_IOPORT
 	select HAVE_ACPI_APEI			if ACPI
 	select HAVE_ACPI_APEI_NMI		if ACPI
 	select HAVE_ALIGNED_STRUCT_PAGE		if SLUB
@@ -2893,6 +2894,7 @@ if X86_32
 
 config ISA
 	bool "ISA support"
+	depends on HAS_IOPORT
 	help
 	  Find out whether you have ISA slots on your motherboard.  ISA is the
 	  name of a bus system, i.e. the way the CPU talks to the other stuff
diff --git a/drivers/bus/Kconfig b/drivers/bus/Kconfig
index 7bfe998f3514..fcfa280df98a 100644
--- a/drivers/bus/Kconfig
+++ b/drivers/bus/Kconfig
@@ -81,7 +81,7 @@ config MOXTET
 config HISILICON_LPC
 	bool "Support for ISA I/O space on HiSilicon Hip06/7"
 	depends on (ARM64 && ARCH_HISI) || (COMPILE_TEST && !ALPHA && !HEXAGON && !PARISC)
-	depends on HAS_IOMEM
+	depends on HAS_IOPORT
 	select INDIRECT_PIO if ARM64
 	help
 	  Driver to enable I/O access to devices attached to the Low Pin
diff --git a/drivers/eisa/Kconfig b/drivers/eisa/Kconfig
index c8bbf90209f5..d3f62de72259 100644
--- a/drivers/eisa/Kconfig
+++ b/drivers/eisa/Kconfig
@@ -5,6 +5,7 @@
 
 config HAVE_EISA
 	bool
+	depends on HAS_IOPORT
 
 menuconfig EISA
 	bool "EISA support"
diff --git a/lib/Kconfig b/lib/Kconfig
index ce2abffb9ed8..5c2da561c516 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -92,6 +92,7 @@ config ARCH_USE_SYM_ANNOTATIONS
 config INDIRECT_PIO
 	bool "Access I/O in non-MMIO mode"
 	depends on ARM64
+	depends on HAS_IOPORT
 	help
 	  On some platforms where no separate I/O space exists, there are I/O
 	  hosts which can not be accessed in MMIO mode. Using the logical PIO
@@ -509,6 +510,9 @@ config HAS_IOMEM
 	depends on !NO_IOMEM
 	default y
 
+config HAS_IOPORT
+	bool
+
 config HAS_IOPORT_MAP
 	bool
 	depends on HAS_IOMEM && !NO_IOPORT_MAP
diff --git a/lib/Kconfig.kgdb b/lib/Kconfig.kgdb
index 3b9a44008433..c68e4d9dcecb 100644
--- a/lib/Kconfig.kgdb
+++ b/lib/Kconfig.kgdb
@@ -121,7 +121,8 @@ config KDB_DEFAULT_ENABLE
 
 config KDB_KEYBOARD
 	bool "KGDB_KDB: keyboard as input device"
-	depends on VT && KGDB_KDB && !PARISC
+	depends on HAS_IOPORT
+	depends on VT && KGDB_KDB
 	default n
 	help
 	  KDB can use a PS/2 type keyboard for an input device
-- 
2.37.2
