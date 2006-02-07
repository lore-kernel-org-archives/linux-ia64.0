From: Keith Owens <kaos@sgi.com>
Date: Tue, 07 Feb 2006 22:37:11 +0000
Subject: Re: [2.6 patch] IA64_GENERIC shouldn't select other stuff
Message-Id: <9883.1139351831@ocs3>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Tue, 07 Feb 2006 23:11:57 BST."
             <20060207221157.GA3524@stusta.de> 
References: <20060207221157.GA3524@stusta.de>
In-Reply-To: <20060207221157.GA3524@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Adrian Bunk (on Tue, 7 Feb 2006 23:11:57 +0100) wrote:
>IA64_GENERIC shouldn't select other stuff.
>
>select'ing ACPI without select'ing PCI had broken ACPI in the past (the 
>current workaround is that ACPI select's PCI).
>
>Select'ing NUMA means that the illegal configuration NUMA=y, FLATMEM=y 
>is possible.
>
>The generic setting might be required in some places, but select'ing 
>some options like NUMA while not select'ing some other similar 
>important options like PCI doesn't make much sense.
>
>
>Signed-off-by: Adrian Bunk <bunk@stusta.de>
>
>--- linux-2.6.16-rc1-mm5-ia64/arch/ia64/Kconfig.old	2006-02-07 23:07:29.000000000 +0100
>+++ linux-2.6.16-rc1-mm5-ia64/arch/ia64/Kconfig	2006-02-07 23:07:55.000000000 +0100
>@@ -72,9 +72,6 @@
> 
> config IA64_GENERIC
> 	bool "generic"
>-	select ACPI
>-	select NUMA
>-	select ACPI_NUMA
> 	help
> 	  This selects the system type of your hardware.  A "generic" kernel
> 	  will run on any supported IA-64 system.  However, if you configure
>

A generic IA64 kernel requires (at least) the ACPI and NUMA options in
order to run on all the IA64 platforms out there.  Omitting those
options and relying on the user to set them by hand is going to cause
more problems.

If anything, there should be more options being set as a side effect of
selecting IA64_GENERIC, including ARCH_DISCONTIGMEM_ENABLE,
ARCH_SPARSEMEM_ENABLE, PCI and even SMP.

