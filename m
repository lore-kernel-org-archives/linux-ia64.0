From: Christoph Hellwig <hch@lst.de>
Date: Tue, 10 Aug 2004 07:14:17 +0000
Subject: Re: r996 - in trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7: . debian
Message-Id: <20040810071417.GA5080@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Btw, where is this patch from and why wasn't it discussed on linux-ia64?

I see the use in it, but it also does for example break the depencies
for all the SN2-only drivers that can now be selected for a UP Generic
driver but won't compile or link.


On Tue, Aug 10, 2004 at 12:32:51AM -0600, Dann Frazier wrote:
> Author: dannf
> Date: 2004-08-10 00:32:39 -0600 (Tue, 10 Aug 2004)
> New Revision: 996
> 
> Added:
>    trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/up-fix.patch
> Removed:
>    trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/patch1.diff
> Modified:
>    trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/debian/changelog
>    trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/debian/rules
> Log:
> rename patch1.diff to more descriptive up-fix.patch
> 
> 
> Modified: trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/debian/changelog
> =================================> --- trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/debian/changelog	2004-08-09 16:45:16 UTC (rev 995)
> +++ trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/debian/changelog	2004-08-10 06:32:39 UTC (rev 996)
> @@ -1,3 +1,10 @@
> +kernel-patch-2.6.7-ia64 (2.6.7-4) UNRELEASED; urgency=low
> +
> +  * dann frazier
> +    - rename patch1.diff to more descriptive up-fix.patch
> +	
> + -- dann frazier <dannf@debian.org>  Sun, 11 Jul 2004 12:09:51 -0600
> +
>  kernel-patch-2.6.7-ia64 (2.6.7-3) unstable; urgency=low
>  
>    * Add module2.patch from:
> 
> Modified: trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/debian/rules
> =================================> --- trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/debian/rules	2004-08-09 16:45:16 UTC (rev 995)
> +++ trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/debian/rules	2004-08-10 06:32:39 UTC (rev 996)
> @@ -14,7 +14,7 @@
>  topdir=$(shell pwd)
>  destdir=${topdir}/debian/tmp
>  docdir=${destdir}/usr/share/doc/${PACKAGE}
> -patches = linux-2.6.7-ia64-040629.diff patch1.diff sym53c8xx_revert.patch \
> +patches = linux-2.6.7-ia64-040629.diff up-fix.patch sym53c8xx_revert.patch \
>            sn_console-erikj-patch devices.txt-patch module2.patch
>  
>  build:	build-stamp
> 
> Deleted: trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/patch1.diff
> =================================> --- trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/patch1.diff	2004-08-09 16:45:16 UTC (rev 995)
> +++ trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/patch1.diff	2004-08-10 06:32:39 UTC (rev 996)
> @@ -1,36 +0,0 @@
> -diff -urN kernel-source-2.6.2.orig/arch/ia64/Kconfig kernel-source-2.6.2/arch/ia64/Kconfig
> ---- kernel-source-2.6.2.orig/arch/ia64/Kconfig	2004-02-05 01:19:28.000000000 -0700
> -+++ kernel-source-2.6.2/arch/ia64/Kconfig	2004-02-15 01:43:29.000000000 -0700
> -@@ -62,10 +62,10 @@
> - 
> - config IA64_GENERIC
> - 	bool "generic"
> --	select NUMA
> --	select ACPI_NUMA
> -+	select NUMA if SMP
> -+	select ACPI_NUMA if SMP
> - 	select VIRTUAL_MEM_MAP
> --	select DISCONTIGMEM
> -+	select DISCONTIGMEM if SMP
> - 	help
> - 	  This selects the system type of your hardware.  A "generic" kernel
> - 	  will run on any supported IA-64 system.  However, if you configure
> -@@ -211,8 +211,8 @@
> - 
> - config NUMA
> - 	bool "NUMA support"
> -+	default y if (IA64_SGI_SN2 || IA64_GENERIC) && SMP
> - 	depends on !IA64_HP_SIM
> --	default y if IA64_SGI_SN2
> - 	help
> - 	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
> - 	  Access).  This option is for configuring high-end multiprocessor
> -diff -urN kernel-source-2.6.2.orig/arch/ia64/sn/Makefile kernel-source-2.6.2/arch/ia64/sn/Makefile
> ---- kernel-source-2.6.2.orig/arch/ia64/sn/Makefile	2004-02-05 01:19:28.000000000 -0700
> -+++ kernel-source-2.6.2/arch/ia64/sn/Makefile	2004-02-15 01:38:43.000000000 -0700
> -@@ -9,4 +9,4 @@
> - # Makefile for the sn ia64 subplatform
> - #
> - 
> --obj-y += kernel/ io/
> -+obj-$(CONFIG_DISCONTIGMEM) += kernel/ io/
> 
> Copied: trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/up-fix.patch (from rev 995, trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7/patch1.diff)
> 
> 
> _______________________________________________
> Kernel-svn-changes mailing list
> Kernel-svn-changes@lists.alioth.debian.org
> http://lists.alioth.debian.org/mailman/listinfo/kernel-svn-changes
---end quoted text---
