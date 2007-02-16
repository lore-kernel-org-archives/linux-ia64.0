From: Horms <horms@verge.net.au>
Date: Fri, 16 Feb 2007 10:35:05 +0000
Subject: Re: [PATCH] kexec: Use EFI_LOADER_DATA for ELF core header (ia64)
Message-Id: <20070216103503.GE18477@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070215135235.24373.87951.sendpatchset@localhost>
In-Reply-To: <20070215135235.24373.87951.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 15, 2007 at 10:52:35PM +0900, Magnus Damm wrote:
> kexec: Use EFI_LOADER_DATA for ELF core header (ia64)
> 
> The address where the ELF core header is stored is passed to the secondary 
> kernel as a kernel command line option. The memory area for this header is 
> also marked as a separate EFI memory descriptor on ia64.
> 
> The separate EFI memory descriptor is at the moment of the type
> EFI_UNUSABLE_MEMORY. With such a type the secondary kernel skips over the
> entire memory granule (config option, 16M or 64M) when detecting memory. 
> If we are lucky we will just lose some memory, but if we happen to have data
> in the same granule (such as an initramfs image), then this data will never
> get mapped and the kernel bombs out when trying to access it.
> 
> So this is an attempt to fix this by changing the EFI memory descriptor
> type into EFI_LOADER_DATA. This type is the same type used for the kernel 
> data and for initramfs. In the secondary kernel we then handle the ELF core 
> header data the same way as we handle the initramfs image.
> 
> This patch contains the kernel changes to make this happen. Pretty
> straightforward, we reserve the area in reserve_memory(). The address
> for the area comes from the kernel command line and the size comes
> from the specialized EFI parsing function vmcore_find_descriptor_size().
> 
> The kexec-tools-testing code for this can be found here:
> http://lists.osdl.org/pipermail/fastboot/2007-February/005983.html

This looks fine to me.

I haven't actually been able to test it because my test environment
is currently playing up and it seems to be past that time on a Friday
where I am capable of fixing such things - I will try again on Monady.

A small comment is that IMHO reserve_elfcorehdr() really ought to
be wrapped in CONFIG_PROC_VMCORE, as its not used unless that
CONFIG_PROC_VMCORE is active.

Something like this...

Index: linux-2.6/arch/ia64/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/kernel/setup.c	2007-02-16 19:16:52.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/setup.c	2007-02-16 19:17:15.000000000 +0900
@@ -460,6 +460,7 @@
 }
 early_param("elfcorehdr", parse_elfcorehdr);
 
+#ifdef CONFIG_PROC_VMCORE
 int __init reserve_elfcorehdr(unsigned long *start, unsigned long *end)
 {
 	unsigned long length;
@@ -482,6 +483,7 @@
 	*end = *start + length;
 	return 0;
 }
+#endif
 
 #endif /* CONFIG_PROC_VMCORE */
 
