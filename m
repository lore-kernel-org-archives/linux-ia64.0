From: "Jun'ichi Nomura" <j-nomura@ce.jp.nec.com>
Date: Tue, 21 Mar 2006 19:23:44 +0000
Subject: Re: [PATCH 1/3] msi vector targeting abstractions
Message-Id: <442052C0.8050304@ce.jp.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060321143444.9913.48372.11324@lnx-maule.americas.sgi.com> <20060321143449.9913.55794.57267@lnx-maule.americas.sgi.com> <442029EA.9020900@ce.jp.nec.com> <jebqvzhhxr.fsf@sykes.suse.de> <20060321191414.GE22524@sgi.com>
In-Reply-To: <20060321191414.GE22524@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: Andreas Schwab <schwab@suse.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, gregkh@suse.de, linux-kernel@vger.kernel.org, linuxppc64-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz

Hi,

Mark Maule wrote:
> @@ -386,5 +390,8 @@
>  #ifndef platform_readq_relaxed
>  # define platform_readq_relaxed	__ia64_readq_relaxed
>  #endif
> +#ifndef platform_msi_init
> +# define platform_msi_init	((ia64_mv_msi_init_t*)NULL)
> +#endif

You may also need to change the sn specific header below.

> @@ -115,6 +116,11 @@
>  #define platform_dma_sync_sg_for_device	sn_dma_sync_sg_for_device
>  #define platform_dma_mapping_error		sn_dma_mapping_error
>  #define platform_dma_supported		sn_dma_supported
> +#ifdef CONFIG_PCI_MSI
> +#define platform_msi_init		sn_msi_init
> +#else
> +#define platform_msi_init		NULL
> +#endif

Thanks,
-- 
Jun'ichi Nomura, NEC Solutions (America), Inc.
