From: Matthew Wilcox <willy@debian.org>
Date: Wed, 17 Mar 2004 20:42:57 +0000
Subject: Re: [PATCH] init IO port space, IO accessors earlier
Message-Id: <20040317204257.GT25059@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403171306.01728.bjorn.helgaas@hp.com>
In-Reply-To: <200403171306.01728.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 17, 2004 at 01:06:01PM -0700, Bjorn Helgaas wrote:
> +io_port_init (void)
> +{
> +	extern unsigned long ia64_iobase;
> +	unsigned long phys_iobase;
> +
> +	/*
> +	 *  Set `iobase' to the appropriate address in region 6 (uncached access range).
> +	 *
> +	 *  The EFI memory map is the "preferred" location to get the I/O port space base,
> +	 *  rather the relying on AR.KR0. This should become more clear in future SAL
> +	 *  specs. We'll fall back to getting it out of AR.KR0 if no appropriate entry is
> +	 *  found in the memory map.
> +	 */

I see you're only moving code here, but could you wrap this comment at
80 columns?

	/*
	 * Set `iobase' to the appropriate address in region 6 (uncached
	 * access range).  The EFI memory map is the "preferred" location
	 * to get the I/O port space base, rather the relying on AR.KR0.
	 * This should become more clear in future SAL specs.   We'll fall
	 * back to getting it out of AR.KR0 if no appropriate entry is
	 * found in the memory map.
	 */

> +	phys_iobase = efi_get_iobase();
> +	if (phys_iobase)
> +		/* set AR.KR0 since this is all we use it for anyway */
> +		ia64_set_kr(IA64_KR_IO_BASE, phys_iobase);
> +	else {
> +		phys_iobase = ia64_get_kr(IA64_KR_IO_BASE);
> +		printk(KERN_INFO "No I/O port range found in EFI memory map, falling back "
> +		       "to AR.KR0\n");

This printk could also be wrapped:

		printk(KERN_INFO "No I/O port range found in EFI memory map, "
			"falling back to AR.KR0\n");

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
