From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 03 Nov 2003 20:47:55 +0000
Subject: Re: [PATCH] Bug in sn_pci_map_sg causes MCA
Message-Id: <marc-linux-ia64-106789253211784@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106789192810902@msgid-missing>
In-Reply-To: <marc-linux-ia64-106789192810902@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David, this fixes a critical bug for us.  Can you push it to Linus or
should we send it straight to Andrew?

Thanks,
Jesse

On Mon, Nov 03, 2003 at 02:36:29PM -0600, Alan Mayer wrote:
> If sg->dma_address is set, we try to do a __pa() on a dma_address,
> then, later, create a dma_addresss from a munged dma_address.  When
> this bogus dma_address is used by the card, it results in MCAs.
> 
> 		--ajm
> 
> 
> 
> --- /usr/tmp/TmpDir.5614-0/linux/arch/ia64/sn/io/machvec/pci_dma.c_1.5  Mon Nov  3 14:32:30 2003
> +++ linux/arch/ia64/sn/io/machvec/pci_dma.c     Mon Nov  3 13:16:20 2003
> @@ -279,8 +279,7 @@
>          * scatterlist.
>          */
>         for (i = 0; i < nents; i++, sg++) {
> -               phys_addr = __pa(sg->dma_address ? sg->dma_address :
> -                       (unsigned long)page_address(sg->page) + sg->offset);
> +               phys_addr = __pa((unsigned long)page_address(sg->page) + sg->offset);
>  
>                 /*
>                  * Handle the most common case: 64 bit cards.  This
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
