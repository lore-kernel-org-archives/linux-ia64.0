From: Alex Chiang <achiang@hp.com>
Date: Thu, 25 Feb 2010 21:09:57 +0000
Subject: [PATCH 2/2] [IA64] build arch/ia64/kernel/acpi-ext.o when CONFIG_ACPI
Message-Id: <20100225210957.23267.98557.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Simplify the makefile slightly by always building acpi-ext.o when
CONFIG_ACPI is turned on.

Yes, this adds a little bloat to the other configs, but not much:
   text	   data	    bss	    dec	    hex	filename
    839	     41	      0	    880	    370	arch/ia64/kernel/acpi-ext.o

Before:
   text	   data	    bss	    dec		    hex	filename
10952753	1299212	1334241	13586206	 cf4f1e	vmlinux

After:
   text	   data	    bss	    dec		    hex	filename
10953739	1299084	1334241	13587064	 cf5278	vmlinux

(gdb) p 13587064 - 13586206
$2 = 858

Seems like a small price to pay for the benefit of not having to think
so hard about the multitude of ia64 configs when reading code/Makefiles.

Signed-off-by: Alex Chiang <achiang@hp.com>
---

 arch/ia64/kernel/Makefile |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 78ad418..4138282 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -13,11 +13,8 @@ obj-y := entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o irq.o irq_ia64
 	 salinfo.o setup.o signal.o sys_ia64.o time.o traps.o unaligned.o \
 	 unwind.o mca.o mca_asm.o topology.o dma-mapping.o
 
-obj-$(CONFIG_ACPI)		+= acpi.o
+obj-$(CONFIG_ACPI)		+= acpi.o acpi-ext.o
 obj-$(CONFIG_IA64_BRL_EMU)	+= brl_emu.o
-obj-$(CONFIG_IA64_GENERIC)	+= acpi-ext.o
-obj-$(CONFIG_IA64_HP_ZX1)	+= acpi-ext.o
-obj-$(CONFIG_IA64_HP_ZX1_SWIOTLB) += acpi-ext.o
 
 obj-$(CONFIG_IA64_PALINFO)	+= palinfo.o
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o

