From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 05 Apr 2006 16:15:34 +0000
Subject: Re: 2.6.17-rc1-mm1
Message-Id: <200604051015.34217.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060404014504.564bf45a.akpm@osdl.org> <20060404233851.GA6411@agluck-lia64.sc.intel.com> <1144202706.3197.11.camel@linux-znh>
In-Reply-To: <1144202706.3197.11.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zou Nan hai <nanhai.zou@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Tuesday 04 April 2006 20:05, Zou Nan hai wrote:
> On Wed, 2006-04-05 at 07:38, Luck, Tony wrote:
> > On Tue, Apr 04, 2006 at 01:45:04AM -0700, Andrew Morton wrote:
> > > - VGA on ia64 is broken - the screen comes up blank.  But ia64 otherwise
> > >   seems to work OK.  I didn't have time to investigate.
> > 
> > Broken in base 2.6.17-rc1 too :-(  VGA comes up and prints a
> > few messages, and then goes wonky and dies.  Comparing
> > what I _think_ I saw with the dmesg output, it appears to
> > die here:
> 
> The wild VGA comes from the patch which changed ioremap.
> 
> Now ioremap would not remap memory to region 6 unless that memory is
> marked as EFI_MEMORY_UC by EFI.
> 
> Unfortunately on the Tiger Machine, VGA ram base was marked as
> EFI_MEMORY_WB instead of EFI_MEMORY_UC...
> 
> So you can see the problem disappear if change VGA_MAP_MEM to use
> ioremap_nocache.
> 
> But I am not quite sure if we can fully trust EFI on this attribute.

Huh.  Intel firmware used to just not mention the VGA framebuffer
(0xa0000-0xc0000) at all in the EFI memory map.  I think that was
clearly a bug.  So maybe they fixed that by marking it WB (and
hopefully UC as well).

Tiger might support WB to the VGA framebuffer, but I don't think it
make much sense for us to use it that way.  If we did, writes to the
framebuffer would just sit in the cache until forced out by something
else.  Probably using WC would be the best, but we don't have a good
interface for that yet.

Tony, if you agree with this analysis and haven't fixed it yet, here's
a trivial patch.


[IA64] always map VGA framebuffer UC, even if it supports WB

EFI on some machines, e.g., Intel Tiger, reports that the VGA framebuffer
supports WB access.  ioremap() prefers WB when possible, so it can work
when mapping main memory.

But it doesn't make sense to map a framebuffer WB, because the driver
doesn't flush explicitly, so updates won't make it to the device
immediately.

This is due to Zou Nan hai <nanhai.zou@intel.com>.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-mm5/include/asm-ia64/vga.h
=================================--- work-mm5.orig/include/asm-ia64/vga.h	2006-01-02 20:21:10.000000000 -0700
+++ work-mm5/include/asm-ia64/vga.h	2006-04-05 09:57:55.000000000 -0600
@@ -17,7 +17,7 @@
 extern unsigned long vga_console_iobase;
 extern unsigned long vga_console_membase;
 
-#define VGA_MAP_MEM(x)	((unsigned long) ioremap(vga_console_membase + (x), 0))
+#define VGA_MAP_MEM(x)	((unsigned long) ioremap_nocache(vga_console_membase + (x), 0))
 
 #define vga_readb(x)	(*(x))
 #define vga_writeb(x,y)	(*(y) = (x))
