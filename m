From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 02 Jun 2015 03:45:07 +0000
Subject: Re: [v3,33/36] genirq: Use helper function to access irq_data->msi_desc
Message-Id: <20150602034507.1BBCB1412F1@ozlabs.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1433145945-789-34-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1433145945-789-34-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiang Liu <jiang.liu@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Bjorn Helgaas <bhelgaas@google.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Randy Dunlap <rdunlap@infradead.org>, Yinghai Lu <yinghai@kernel.org>, Borislav Petkov <bp@alien8.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@ezchip.com>, Jiang Liu <jiang.liu@linux.intel.com>, Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <tj@kernel.org>, Joe Perches <joe@perches.com>
Cc: linux-ia64@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Mon, 2015-01-06 at 08:05:42 UTC, Jiang Liu wrote:
> Use irq_data access helper to access irq_data->msi_desc, so we could
> move msi_desc from struct irq_data into struct irq_common_data later.
> 
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>  arch/powerpc/sysdev/xics/ics-opal.c |    2 +-
>  arch/powerpc/sysdev/xics/ics-rtas.c |    2 +-
> 
> diff --git a/arch/powerpc/sysdev/xics/ics-opal.c b/arch/powerpc/sysdev/xics/ics-opal.c
> index 3996393c254d..27c936c080a6 100644
> --- a/arch/powerpc/sysdev/xics/ics-opal.c
> +++ b/arch/powerpc/sysdev/xics/ics-opal.c
> @@ -72,7 +72,7 @@ static unsigned int ics_opal_startup(struct irq_data *d)
>  	 * card, using the MSI mask bits. Firmware doesn't appear to unmask
>  	 * at that level, so we do it here by hand.
>  	 */
> -	if (d->msi_desc)
> +	if (irq_data_get_msi_desc(d))
>  		pci_msi_unmask_irq(d);
>  #endif
>  
> diff --git a/arch/powerpc/sysdev/xics/ics-rtas.c b/arch/powerpc/sysdev/xics/ics-rtas.c
> index e2665a9dfc0f..3854dd41558d 100644
> --- a/arch/powerpc/sysdev/xics/ics-rtas.c
> +++ b/arch/powerpc/sysdev/xics/ics-rtas.c
> @@ -75,7 +75,7 @@ static unsigned int ics_rtas_startup(struct irq_data *d)
>  	 * card, using the MSI mask bits. Firmware doesn't appear to unmask
>  	 * at that level, so we do it here by hand.
>  	 */
> -	if (d->msi_desc)
> +	if (irq_data_get_msi_desc(d))
>  		pci_msi_unmask_irq(d);
>  #endif
>  	/* unmask it */

These look OK.

Though I would point out we already have 16 irq_foo_get_bar() accessors?!

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers
