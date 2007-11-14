From: Simon Horman <horms@verge.net.au>
Date: Wed, 14 Nov 2007 22:00:01 +0000
Subject: Re: [PATCH] iounmap after ioremap in efi_enter_virtual_mode, file arch/ia64/kernel/efi.c
Message-Id: <20071114215952.GE2368@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <472D0486.8080604@tiscali.nl>
In-Reply-To: <472D0486.8080604@tiscali.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 05, 2007 at 09:45:27AM +0100, Roel Kluin wrote:
> Simon Horman wrote:
> > On Sun, Nov 04, 2007 at 12:30:14AM +0100, Roel Kluin wrote:
> >> I am less certain about this one, so please review
> >> --
> >> Iounmap when EFI won't switch to virtual mode
> >>
> 
> > 
> > Hi Roel,
> > 
> > I'm not really sure what the intention of this patch is.
> > But I'm pretty sure its not doing what you want it to do.
> > 
> > I guess that you wish to reverse all the calls to ioremap()
> > that are made in efi_enter_virtual_mode(). ioremap() is
> > called during iterating through efi_map_start, but you only
> > seem to call iounmap on whatever md happens to be set
> > to at the end of the iteration. Surely you need to run through
> > efi_map_start again?
> 
> Yes, you are right, this was what I had in mind:
> --
>  	if (status != EFI_SUCCESS) {
> +                for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
> +			md = p;
> +			if ((md->attribute & EFI_MEMORY_RUNTIME) &&
> +			    (md->attribute & EFI_MEMORY_UC) ||
> +			    (md->attribute & EFI_MEMORY_WC))

I think that you also need || (md->attribute & EFI_MEMORY_WT)

or in other words
			if ((md->attribute & EFI_MEMORY_RUNTIME) &&
			    (md->attribute &
			     EFI_MEMORY_UC|EFI_MEMORY_WC|EFI_MEMORY_WT))

> +				iounmap(md->virt_addr);
> +		}
>  		printk(KERN_WARNING "warning: unable to switch EFI into virtual mode "
>  		       "(status=%lu)\n", status);
>  		return;

Otherwise, yes, that is what I was thinking.

> ---
> 
> > The next thing that I wonder about is weather calling iounmap()
> > actually reverses ioremap() in this case. Though now that I look
> > at it and see that basically iounmap() will do nothing in
> > this case, which seems appropriate as in this case ioremap()
> > ends up being:
> > 
> >    return (void __iomem *) (__IA64_UNCACHED_OFFSET | phys_addr)
> > 
> > Its probably not to much of a bother that all the md->virt_addr have
> > been mangled and stay mangled. Though if we are concerned about such
> > things, perhaps it would be cleaner to zero them on error?
> > 
> 
> Like this?

Yes, though I guess that iounmap() should also be called.
And as I mentioned before, I'm not sure if doing this is worthwhile or
not.

On a fresh boot its likely that md->virt_addr is initialised
to 0 for each md (I ought to check the spec). But, for instance,
in a second kernel botoed by kexec, virt_addr may well be non-zero,
indicating the values that were set in the previous boot. Incidently
efi_call_phys() really ought to fail on in that case, though
it doesn't as kexec replaces it with a noop.

So I'm not sure if reseting the value to 0 has any use.
Though it does feel clean to me.

> 
> ---
>  	if (status != EFI_SUCCESS) {
> +                for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
> +			md = p;
> +			if ((md->attribute & EFI_MEMORY_RUNTIME) &&
> +			    (md->attribute & EFI_MEMORY_UC) ||
> +			    (md->attribute & EFI_MEMORY_WC))
> +				md->virt_addr = 0;
> +		}
>  		printk(KERN_WARNING "warning: unable to switch EFI into virtual mode "
>  		       "(status=%lu)\n", status);
>  		return;
> ---
> 
> I fear the remainder of your review is beyond my scope. My field of
> expertise is biomedical sciences :)
> 
> Roel
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms, California Edition

