From: Andrew Morton <akpm@linux-foundation.org>
Date: Sat, 17 May 2008 16:46:08 +0000
Subject: Re: [patch] Fix Altix boot breakage in ACPI
Message-Id: <20080517094608.9b924dc6.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080516202020.GA21250@sgi.com>
In-Reply-To: <20080516202020.GA21250@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 17 May 2008 09:10:35 -0500 Russ Anderson <rja@sgi.com> wrote:

> On Fri, May 16, 2008 at 03:40:28PM -0700, Luck, Tony wrote:
> > > A recent ACPI change (commit 5dc90c0b2d4bd0127624bab67cec159b2c6c4daf)
> > 
> > -ENOSUCHCOMMIT ... well I can't see it in Linus' tree.
> 
> Sorry, I should have added more information.
> 
> It is in Andrew's tree (2.6.26-rc2-mm1).  It has yet to make it to Linus' tree.
> 
> http://lkml.org/lkml/2008/5/14/366
> 
> The patch name is acpi-acpi_numa_init-build-fix
> http://kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc2/2.6.26-rc2-mm1/patch-list

That was dropped because it broke things.  umm...

	From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
	To: "Andrew Morton" <akpm@linux-foundation.org>
	Cc: linux-kernel@vger.kernel.org
	Subject: Re: 2.6.26-rc2-mm1
	Date: 	Wed, 14 May 2008 21:12:13 +0200
	Sender: linux-kernel-owner@vger.kernel.org
	...
	But somehow the NUMAness of my system is gone.

> A recent ACPI change (commit 5dc90c0b2d4bd0127624bab67cec159b2c6c4daf)
> inadvertently broke Altix boot.  This patch allow Altix to boot.
> 
> 
> Signed-off-by: Russ Anderson <rja@sgi.com>
> Acked-by: Ingo Molnar <mingo@elte.hu>
> 
> ---
>  arch/ia64/Kconfig    |    4 ++++
>  include/linux/acpi.h |    2 +-
>  2 files changed, 5 insertions(+), 1 deletion(-)
> 
> Index: 2.6.26-rc2/arch/ia64/Kconfig
> =================================> --- 2.6.26-rc2.orig/arch/ia64/Kconfig	2008-05-16 09:36:37.285558037 -0500
> +++ 2.6.26-rc2/arch/ia64/Kconfig	2008-05-16 09:37:39.149204580 -0500
> @@ -60,6 +60,10 @@ config RWSEM_XCHGADD_ALGORITHM
>  	bool
>  	default y
>  
> +config HAVE_ARCH_PARSE_SRAT
> +	bool
> +	default y
> +
>  config ARCH_HAS_ILOG2_U32
>  	bool
>  	default n
> Index: 2.6.26-rc2/include/linux/acpi.h
> =================================> --- 2.6.26-rc2.orig/include/linux/acpi.h	2008-05-16 09:37:12.989971159 -0500
> +++ 2.6.26-rc2/include/linux/acpi.h	2008-05-16 09:50:17.082906375 -0500
> @@ -93,7 +93,7 @@ int acpi_parse_mcfg (struct acpi_table_h
>  void acpi_table_print_madt_entry (struct acpi_subtable_header *madt);
>  
>  /* the following four functions are architecture-dependent */
> -#ifdef CONFIG_HAVE_ARCH_PARSE_SRAT
> +#if defined(CONFIG_HAVE_ARCH_PARSE_SRAT) && !defined(NR_NODE_MEMBLKS)
>  #define NR_NODE_MEMBLKS MAX_NUMNODES
>  #define acpi_numa_slit_init(slit) do {} while (0)
>  #define acpi_numa_processor_affinity_init(pa) do {} while (0)

So this affects machines other than altix?

Who gets to merge this?  I'll plan on sending it in on Mondayish unless
I hear otherwise.

(I wish the changelog was more specific than "inadvertently broke".  It
should explain what the failure was).

