From: Judith Lebzelter <judith@osdl.org>
Date: Wed, 12 Jan 2005 00:47:04 +0000
Subject: Re: [patch 1/3] Replace pci_find_device with pci_get_device
Message-Id: <Pine.LNX.4.33.0501111627050.23999-100000@osdlab.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050110194632.475A61F203@trashy.coderock.org>
In-Reply-To: <20050110194632.475A61F203@trashy.coderock.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 10 Jan 2005 domen@coderock.org wrote:

>
>
>
> As pci_find_device is going away soon I have replaced the call with pci_get_device.
> Judith, could you run these 3 ia64 ones through PLM, please? This should complete the
> arch/ia64 conversion.
>
> Thanks a lot.

Sorry this took a while to get to, I was out yesterday.  I ran the
submitted the 3 patches on linux-2.6.10 and the results are here:
   http://www.osdl.org/plm-cgi/plm?module=patch_info&patch_id@63

   Summary:
   Making vmlinux (defconfig): 9 warnings, 0 errors
   Making modules (defconfig): 62 warnings, 0 errors
   Making vmlinux (allnoconfig): 6 warnings, 5 errors
   Making vmlinux (allyesconfig): 854 warnings, 25 errors
   Making modules (allyesconfig): 8 warnings, 0 errors
   Making vmlinux (allmodconfig): 8 warnings, 0 errors
   Making modules (allmodconfig): 854 warnings, 11 errors

linux-2.6.10 is at:
   http://www.osdl.org/plm-cgi/plm?module=patch_info&patch_id@24

   Summary:
   Making vmlinux (defconfig): 14 warnings, 0 errors
   Making modules (defconfig): 65 warnings, 0 errors
   Making vmlinux (allnoconfig): 6 warnings, 5 errors
   Making vmlinux (allyesconfig): 854 warnings, 25 errors
   Making modules (allyesconfig): 8 warnings, 0 errors
   Making vmlinux (allmodconfig): 8 warnings, 0 errors
   Making modules (allmodconfig): 854 warnings, 11 errors

This 'compregress' filter runs quite few compiles; the summary is above.
Your patch got the same number of errors, but 8 _fewer_ warnings.  Five
of those warnings in 2.6.10 were due unfortunately to my 'clock skew',
which I just recently fixed.

Judith

>
> Hanna Linder
> IBM Linux Technology Center
>
> Signed-off-by: Hanna Linder <hannal@us.ibm.com>
> Acked-by: Judith Lebzelter <judith@osdl.org>
> Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
>
> ---
>
> Signed-off-by: Domen Puncer <domen@coderock.org>
> ---
>
>
>  kj-domen/arch/ia64/hp/common/sba_iommu.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
>
> diff -puN arch/ia64/hp/common/sba_iommu.c~pci_dev_present-arch_ia64_hp_common_sba_iommu arch/ia64/hp/common/sba_iommu.c
> --- kj/arch/ia64/hp/common/sba_iommu.c~pci_dev_present-arch_ia64_hp_common_sba_iommu	2005-01-10 18:00:14.000000000 +0100
> +++ kj-domen/arch/ia64/hp/common/sba_iommu.c	2005-01-10 18:00:14.000000000 +0100
> @@ -1557,7 +1557,7 @@ ioc_iova_init(struct ioc *ioc)
>  	** We program the next pdir index after we stop w/ a key for
>  	** the GART code to handshake on.
>  	*/
> -	while ((device = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, device)) != NULL)
> +	while ((device = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, device)) != NULL)
>  		agp_found |= pci_find_capability(device, PCI_CAP_ID_AGP);
>
>  	if (agp_found && reserve_sba_gart) {
> _
>

