From: Matthew Wilcox <willy@debian.org>
Date: Wed, 16 Jul 2003 19:40:51 +0000
Subject: Re: [Discontig-devel] [PATCH] another discontig patch
Message-Id: <marc-linux-ia64-105838466129009@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105618641519753@msgid-missing>
In-Reply-To: <marc-linux-ia64-105618641519753@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 16, 2003 at 12:29:52PM -0700, Jesse Barnes wrote:
> @@ -210,8 +210,8 @@
>  	  system with an A0 or A1 stepping CPU.
>  
>  config NUMA
> -	bool "Enable NUMA support" if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
> -	default y if IA64_SGI_SN2
> +	bool
> +	default y if IA64_SGI_SN2 || IA64_GENERIC
>  	help
>  	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
>  	  Access).  This option is for configuring high-end multiprocessor

If you're removing the question, you can remove the helptext too.

> @@ -235,8 +235,7 @@
>  
>  config DISCONTIGMEM
>  	bool
> -	depends on IA64_SGI_SN2 || (IA64_GENERIC || IA64_DIG || IA64_HP_ZX1) && NUMA
> -	default y
> +	default y if IA64_SGI_SN2 || IA64_GENERIC
>  	help
>  	  Say Y to support efficient handling of discontiguous physical memory,
>  	  for architectures which are either NUMA (Non-Uniform Memory Access)

This one already shouldn't have helptext ;-)

> - * on a BANKSIZE boundary.  Multiple banks per node is not supported.
> + * on a GRANULE boundary.  Multiple banks per node is not supported.

Multiple banks *are* not supported ;-)  The feature of multiple banks
*is* not supported.

> @@ -22,15 +22,17 @@
>  
>  struct pglist_data;
>  struct ia64_node_data {
> -	short			active_cpu_count;
>  	short			node;
> +	short			active_cpu_count;
> +	/*
> +	 * The fields are read-only (after boot). They contain pointers to various structures
> +	 * located on other nodes. Ths data is replicated on each node in order to reduce
> +	 * off-node references.
> +	 */

Can you wrap comments at 80 columns?  It makes them much easier to read.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
