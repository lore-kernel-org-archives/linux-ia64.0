From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 24 Apr 2003 22:37:00 +0000
Subject: Re: [Linux-ia64] [PATCH] 1/4 multi-ioport space support for 2.5
Message-Id: <marc-linux-ia64-105590723705603@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705599@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705599@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn, what about the patches posted in this thread?

http://marc.theaimsgroup.com/?t4359481700001&r=1&w=2

They seem to deal with the legacy resource issue quite nicely, and for
the non-legacy case, pci_fixup should be making the
pci_dev->resource[] arrays contain valid I/O addresss, shouldn't it?

Or do you have something else in mind?

Thanks,
Jesse

On Thu, Apr 24, 2003 at 04:25:26PM -0600, Bjorn Helgaas wrote:
> This has been in my 2.4 BK tree for a while, but I should have
> posted it in case there's feedback from other people working
> on large machines.  So here it is, in four parts:
> 
>   1  enhance __ia64_mk_io_addr(port)
>   2  enhance pcibios_scan_root to get multiple mem & io windows
>       from ACPI _CRS, and fixup all the resources
>   3  add support for /proc/iomem and /proc/ioports
>   4  trivial (whitespace, copyright, and move pcibios_fixup_device_resources
>        closer to related code)
> 
> The current scheme is that IO ports are 64 bits, with the low 24
> bits being the port number within an IO port space, and the upper
> bits identifying the space.  There is currently a limit of 16
> spaces.
> 
> Bjorn
> 
> diff -u -ur linux-2.5.67-ia64-030416/arch/ia64/kernel/setup.c linux-2.5.67-ia64-030416-io1/arch/ia64/kernel/setup.c
> --- linux-2.5.67-ia64-030416/arch/ia64/kernel/setup.c	2003-04-24 10:10:58.000000000 -0600
> +++ linux-2.5.67-ia64-030416-io1/arch/ia64/kernel/setup.c	2003-04-24 11:01:40.000000000 -0600
> @@ -63,6 +63,8 @@
>  struct screen_info screen_info;
>  
>  unsigned long ia64_iobase;	/* virtual address for I/O accesses */
> +struct io_space io_space[MAX_IO_SPACES];
> +unsigned int num_io_spaces;
>  
>  unsigned char aux_device_present = 0xaa;        /* XXX remove this when legacy I/O is gone */
>  
> @@ -415,6 +417,11 @@
>  	}
>  	ia64_iobase = (unsigned long) ioremap(phys_iobase, 0);
>  
> +	/* setup legacy IO port space */
> +	io_space[0].mmio_base = ia64_iobase;
> +	io_space[0].sparse = 1;
> +	num_io_spaces = 1;
> +
>  #ifdef CONFIG_SMP
>  	cpu_physical_id(0) = hard_smp_processor_id();
>  #endif
> diff -u -ur linux-2.5.67-ia64-030416/include/asm-ia64/io.h linux-2.5.67-ia64-030416-io1/include/asm-ia64/io.h
> --- linux-2.5.67-ia64-030416/include/asm-ia64/io.h	2003-04-24 10:10:58.000000000 -0600
> +++ linux-2.5.67-ia64-030416-io1/include/asm-ia64/io.h	2003-04-24 11:29:59.000000000 -0600
> @@ -32,6 +32,24 @@
>   */
>  #define IO_SPACE_LIMIT		0xffffffffffffffffUL
>  
> +#define MAX_IO_SPACES			16
> +#define IO_SPACE_BITS			24
> +#define IO_SPACE_SIZE			(1UL << IO_SPACE_BITS)
> +
> +#define IO_SPACE_NR(port)		((port) >> IO_SPACE_BITS)
> +#define IO_SPACE_BASE(space)		((space) << IO_SPACE_BITS)
> +#define IO_SPACE_PORT(port)		((port) & (IO_SPACE_SIZE - 1))
> +
> +#define IO_SPACE_SPARSE_ENCODING(p)	((((p) >> 2) << 12) | (p & 0xfff))
> +
> +struct io_space {
> +	unsigned long mmio_base;	/* base in MMIO space */
> +	int sparse;
> +};
> +
> +extern struct io_space io_space[];
> +extern unsigned int num_io_spaces;
> +
>  # ifdef __KERNEL__
>  
>  #include <asm/machvec.h>
> @@ -80,11 +98,17 @@
>  static inline void*
>  __ia64_mk_io_addr (unsigned long port)
>  {
> -	const unsigned long io_base = __ia64_get_io_port_base();
> -	unsigned long addr;
> +	struct io_space *space;
> +	unsigned long offset;
> +
> +	space = &io_space[IO_SPACE_NR(port)];
> +	port = IO_SPACE_PORT(port);
> +	if (space->sparse)
> +		offset = IO_SPACE_SPARSE_ENCODING(port);
> +	else
> +		offset = port;
>  
> -	addr = io_base | ((port >> 2) << 12) | (port & 0xfff);
> -	return (void *) addr;
> +	return (void *) (space->mmio_base | offset);
>  }
>  
>  /*
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

