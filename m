From: Greg KH <greg@kroah.com>
Date: Wed, 30 Mar 2005 05:58:19 +0000
Subject: Re: [PATCH 3/91] get rid of pci_find_{device,subsys} arch/ia64
Message-Id: <20050330055819.GB10231@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050329122242.GA26755@infradead.org>
In-Reply-To: <20050329122242.GA26755@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 29, 2005 at 05:50:09PM +0530, Amit Gud wrote:
> Replace pci_find_{device,subsys} with pci_get_{device,subsys}.
> 
> 
> 
> Signed-off-by: Amit Gud <gud@eth.net>
> 
> ---
> diff -upr orig-2.6.12-rc1/arch/ia64/sn/kernel/io_init.c work-2.6.12-rc1/arch/ia64/sn/kernel/io_init.c
> --- orig-2.6.12-rc1/arch/ia64/sn/kernel/io_init.c	2005-03-15 21:00:10.000000000 +0530
> +++ work-2.6.12-rc1/arch/ia64/sn/kernel/io_init.c	2005-03-24 15:29:23.539955472 +0530
> @@ -365,8 +365,9 @@ static int __init sn_pci_init(void)
>  	 */
>  
>  	while ((pci_dev > -		pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pci_dev)) != NULL) {
> +		pci_get_device(PCI_ANY_ID, PCI_ANY_ID, pci_dev)) != NULL) {
>  		sn_pci_fixup_slot(pci_dev);
> +		pci_dev_put(dev);
>  	}

Argh, no, this is wrong.  And I think you did this in every one of the
patches you sent out, so please send a retraction for every one of them
too, I don't feel like doing it...

You should not do a pci_dev_put() in a loop like this.  Please go read
the documentation for the pci_get_device() function, it explains how to
use it...

So, sorry, but I'm not going to apply any of these patches.

Next time try sending just a few of them out, to see what the reaction
is, and if you are doing it properly.

greg k-h
