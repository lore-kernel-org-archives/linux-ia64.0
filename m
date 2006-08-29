From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 29 Aug 2006 19:38:46 +0000
Subject: Re: IA64 kexec/kdump 2.6.18-rc5 patch
Message-Id: <200608291338.47345.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1156837594.2598.15.camel@linux-znh>
In-Reply-To: <1156837594.2598.15.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 29 August 2006 01:46, Zou Nan hai wrote:
> +#ifdef CONFIG_KEXEC
> +void
> +ioc_iova_disable(void)
> +{

Ugh.  If you really need this functionality (which I have to say looks
like a band-aid), it probably should be a platform vector.  And should
be split into a separate patch.

> +	struct ioc *ioc;
> +
> +	ioc = ioc_list;
> +
> +	while (ioc != NULL) {
> +		/* Disable IOVA translation */
> +		WRITE_REG(ioc->ibase & 0xfffffffffffffffe, ioc->ioc_hpa + IOC_IBASE);
> +		READ_REG(ioc->ioc_hpa + IOC_IBASE);
> +
> +		/* Clear I/O TLB of any possible entries */
> +		WRITE_REG(ioc->ibase | (get_iovp_order(ioc->iov_size) + iovp_shift), ioc->ioc_hpa + IOC_PCOM);
> +		READ_REG(ioc->ioc_hpa + IOC_PCOM);

This will just make any future device DMA attempts fail with an MCA,
won't it?  What problem does that solve?  Don't you need the same
for other IOMMUs like SGI's?

> +config KEXEC
> +	bool "kexec system call (EXPERIMENTAL)"
> +	depends on EXPERIMENTAL
> +	help
> +	  kexec is a system call that implements the ability to shutdown your
> +	  current kernel, and to start another kernel.  It is like a reboot
> +	  but it is indepedent of the system firmware.   And like a reboot
independent

> +	  you can start any kernel with it, not just Linux.
> +
> +	  The name comes from the similiarity to the exec system call.
similarity


> +size_t copy_oldmem_page(unsigned long pfn, char *buf,
> +                               size_t csize, unsigned long offset, int userbuf)

Doesn't seem to be used.

> +static void device_shootdown(void)
> +{
> +	kdump_disable_iosapic();
> +#ifdef CONFIG_IA64_HP_ZX1
> +	ioc_iova_disable();
> +#endif

Seems like sort of a heavy-handed way to shut down devices.  But maybe
you don't have any alternatives, I don't know.  I guess you don't do
the pci_disable_device() thing here just to avoid depending on more
code?

> +}
> +
> +static inline Elf64_Word
> +*append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
> +		size_t data_len)
> +{

All this ELF stuff looks like something that could be split into
a separate patch.

> +	ia64_dump_cpu_regs(dst);
> +        cfm = dst[43];
> +        sol = (cfm >> 7) & 0x7f;
> +        sof = cfm & 0x7f;
> +        dst[46] = (unsigned long)ia64_rse_skip_regs((unsigned long *)dst[46],
> +                        sof - sol);
> +
> +        buf = (u64 *) per_cpu_ptr(crash_notes, cpu);

Funny indentation above (spaces rather than tab, I guess).

> -static unsigned long mem_limit = ~0UL, max_addr = ~0UL;
> +static unsigned long mem_limit = ~0UL, max_addr = ~0UL, min_addr = 0UL;
>  
>  #define efi_call_virt(f, args...)	(*(f))(args)
>  
> @@ -421,6 +422,8 @@ efi_init (void)
>  			mem_limit = memparse(cp + 4, &cp);
>  		} else if (memcmp(cp, "max_addr=", 9) = 0) {
>  			max_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
> +		} else if (memcmp(cp, "min_addr=", 9) = 0) {
> +			min_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));

min_addr= looks like it could be a separate patch.

> +#ifdef CONFIG_CRASH_DUMP
> +void
> +kdump_disable_iosapic(void)
> +{
> +	u32 low32;
> +	struct iosapic_intr_info *info;
> +	struct iosapic_rte_info *rte;
> +	for (info = iosapic_intr_info; info <
> +			iosapic_intr_info + IA64_NUM_VECTORS; ++info) {
> +		low32 = info->low32 |= IOSAPIC_MASK;
> +		list_for_each_entry(rte, &info->rtes,
> +				rte_list) {
> +			iosapic_write(rte->addr,
> +					IOSAPIC_RTE_LOW(rte->rte_index), low32);
> +		}
> +	}
> +}
> +#endif

Disabling the iosapic could be a separate patch.

> +/*
> + * Do what every setup is needed on image and the
ever

> +#ifdef CONFIG_KEXEC
> +	/* crashkernel=size@addr specifies the location to reserve for
> +	 * a crash kernel.  By reserving this memory we guarantee
> +	 * that linux never set's it up as a DMA target.
sets, or better, s/set's it up/uses it/

> +	 * Useful for holding code to do something appropriate
> +	 * after a kernel panic.
> +	 */
> +	{
> +		char *from = strstr(saved_command_line, "crashkernel=");

crashkernel= looks like it could be a separate patch.

> +		char *from = strstr(saved_command_line, "elfcorehdr=");
> +
> +		if (from)
> +			elfcorehdr_addr = memparse(from+11, &from);

elfcorehdr_addr isn't referenced anywhere else.

> diff -Nraup linux-2.6.18-rc5/kernel/irq/manage.c linux-2.6.18-rc5-kdump/kernel/irq/manage.c
> --- linux-2.6.18-rc5/kernel/irq/manage.c	2006-08-30 11:37:00.000000000 +0800
> +++ linux-2.6.18-rc5-kdump/kernel/irq/manage.c	2006-08-30 10:34:25.000000000 +0800
> @@ -475,4 +475,3 @@ int request_irq(unsigned int irq,
>  	return retval;
>  }
>  EXPORT_SYMBOL(request_irq);
> -

Extraneous whitespace change.
