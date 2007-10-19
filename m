From: Bernhard Walle <bwalle@suse.de>
Date: Fri, 19 Oct 2007 14:48:28 +0000
Subject: Re: [patch 1/3] Add BSS to resource tree
Message-Id: <20071019144827.GA14023@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071018111535.356215664@strauss.suse.de> <20071018111535.883533731@strauss.suse.de> <20071018142642.5b3f6ba4.akpm@linux-foundation.org>
In-Reply-To: <20071018142642.5b3f6ba4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, kexec@lists.infradead.org, ak@suse.de, vgoyal@in.ibm.com, linux-ia64@vger.kernel.org

* Andrew Morton <akpm@linux-foundation.org> [2007-10-18 23:26]:
> On Thu, 18 Oct 2007 13:15:36 +0200
> Bernhard Walle <bwalle@suse.de> wrote:
> 
> > This patch adds the BSS to the resource tree just as kernel text and kernel
> > data are in the resource tree. The main reason behind this is to avoid
> > crashkernel reservation in that area.
> > 
> > While it's not strictly necessary to have the BSS in the resource tree
> > (the actual collision detection is done in the reserve_bootmem() function
> > before), the usage of the BSS resource should be presented to the user
> > in /proc/iomem just as Kernel data and Kernel code.
> > 
> > Note: The patch currently is only implemented for x86 and ia64 (because
> > efi_initialize_iomem_resources() has the same signature on i386 and
> > ia64).
> > 
> > 
> > ...
> >
> > -extern char _text[], _end[], _etext[];
> > +
> > +static struct resource bss_resource = {
> > +	.name	= "Kernel bss",
> > +	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
> > +};
> > +extern char _text[], _end[], _etext[], _edata[], _bss[];
> 
> These should be in a header file.

It's already ... the problem just was that IA64 uses _bss instead of
__bss_start. So I think we should change this. I verified that the
kernel still compiles with the patch below.


Thanks,
   Bernhard

---
[PATCH] Rename _bss to __bss_start

Rename _bss to __bss_start as on other architectures. That makes it possible to
use the <linux/sections.h> instead of own declarations. Also add __bss_stop
because that symbol exists on other architectures.

That patch applies to current git plus kexec-add-bss-to-resource-tree.patch in
-mm tree.


Signed-off-by: Bernhard Walle <bwalle@suse.de>

---
 arch/ia64/hp/sim/boot/bootloader.lds |    3 ++-
 arch/ia64/kernel/setup.c             |    3 +--
 arch/ia64/kernel/vmlinux.lds.S       |    3 ++-
 3 files changed, 5 insertions(+), 4 deletions(-)

--- a/arch/ia64/hp/sim/boot/bootloader.lds
+++ b/arch/ia64/hp/sim/boot/bootloader.lds
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
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
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
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
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
 


