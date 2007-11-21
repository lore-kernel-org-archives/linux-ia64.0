From: akpm@linux-foundation.org
Date: Wed, 21 Nov 2007 22:58:25 +0000
Subject: [patch 2/3] ia64: rename _bss to __bss_start
Message-Id: <200711212258.lALMwPZc013402@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Bernhard Walle <bwalle@suse.de>

Rename _bss to __bss_start as on other architectures.  That makes it
possible to use the <linux/sections.h> instead of own declarations.  Also
add __bss_stop because that symbol exists on other architectures.

Signed-off-by: Bernhard Walle <bwalle@suse.de>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/hp/sim/boot/bootloader.lds |    3 ++-
 arch/ia64/kernel/setup.c             |    3 +--
 arch/ia64/kernel/vmlinux.lds.S       |    3 ++-
 3 files changed, 5 insertions(+), 4 deletions(-)

diff -puN arch/ia64/hp/sim/boot/bootloader.lds~rename-_bss-to-__bss_start arch/ia64/hp/sim/boot/bootloader.lds
--- a/arch/ia64/hp/sim/boot/bootloader.lds~rename-_bss-to-__bss_start
+++ a/arch/ia64/hp/sim/boot/bootloader.lds
@@ -22,10 +22,11 @@ SECTIONS
   .sdata     : { *(.sdata) }
   _edata  =  .;
 
-  _bss = .;
+  __bss_start = .;
   .sbss      : { *(.sbss) *(.scommon) }
   .bss       : { *(.bss) *(COMMON) }
   . = ALIGN(64 / 8);
+  __bss_stop = .;
   _end = . ;
 
   /* Stabs debugging sections.  */
diff -puN arch/ia64/kernel/setup.c~rename-_bss-to-__bss_start arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c~rename-_bss-to-__bss_start
+++ a/arch/ia64/kernel/setup.c
@@ -95,7 +95,6 @@ static struct resource bss_resource = {
 	.name	= "Kernel bss",
 	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
 };
-extern char _text[], _end[], _etext[], _edata[], _bss[];
 
 unsigned long ia64_max_cacheline_size;
 
@@ -206,7 +205,7 @@ static int __init register_memory(void)
 	code_resource.end   = ia64_tpa(_etext) - 1;
 	data_resource.start = ia64_tpa(_etext);
 	data_resource.end   = ia64_tpa(_edata) - 1;
-	bss_resource.start  = ia64_tpa(_bss);
+	bss_resource.start  = ia64_tpa(__bss_start);
 	bss_resource.end    = ia64_tpa(_end) - 1;
 	efi_initialize_iomem_resources(&code_resource, &data_resource,
 			&bss_resource);
diff -puN arch/ia64/kernel/vmlinux.lds.S~rename-_bss-to-__bss_start arch/ia64/kernel/vmlinux.lds.S
--- a/arch/ia64/kernel/vmlinux.lds.S~rename-_bss-to-__bss_start
+++ a/arch/ia64/kernel/vmlinux.lds.S
@@ -240,11 +240,12 @@ SECTIONS
   .sdata : AT(ADDR(.sdata) - LOAD_OFFSET)
 	{ *(.sdata) *(.sdata1) *(.srdata) }
   _edata  =  .;
-  _bss = .;
+  __bss_start = .;
   .sbss : AT(ADDR(.sbss) - LOAD_OFFSET)
 	{ *(.sbss) *(.scommon) }
   .bss : AT(ADDR(.bss) - LOAD_OFFSET)
 	{ *(.bss) *(COMMON) }
+  __bss_stop = .;
 
   _end = .;
 
_
