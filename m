From: "Jun'ichi Nomura" <j-nomura@ce.jp.nec.com>
Date: Tue, 21 Mar 2006 16:29:30 +0000
Subject: Re: [PATCH 1/3] msi vector targeting abstractions
Message-Id: <442029EA.9020900@ce.jp.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060321143444.9913.48372.11324@lnx-maule.americas.sgi.com> <20060321143449.9913.55794.57267@lnx-maule.americas.sgi.com>
In-Reply-To: <20060321143449.9913.55794.57267@lnx-maule.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: linuxppc64-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, gregkh@suse.de

Hi Mark,

Mark Maule wrote:
> Index: linux-2.6.16/include/asm-ia64/msi.h
> =================================> --- linux-2.6.16.orig/include/asm-ia64/msi.h	2006-03-19 23:53:29.000000000 -0600
> +++ linux-2.6.16/include/asm-ia64/msi.h	2006-03-20 14:50:53.331368084 -0600
> @@ -14,4 +14,16 @@
>  #define ack_APIC_irq		ia64_eoi
>  #define MSI_TARGET_CPU_SHIFT	4
>  
> +extern struct msi_ops msi_apic_ops;
> +
> +static inline int msi_arch_init(void)
> +{
> +	if (platform_msi_init)
> +		return platform_msi_init();
> +
> +	/* default ops for most ia64 platforms */
> +	msi_register(&msi_apic_ops);
> +	return 0;
> +}
> +
>  #endif /* ASM_MSI_H */

It turned out that the above code breaks configs other
than CONFIG_IA64_SN and CONFIG_IA64_GENERIC.
e.g. CONFIG_IA64_DIG.

In file included from /build/16.msi/drivers/pci/msi.h:71,
                 from /build/16.msi/drivers/pci/msi.c:24:
include2/asm/msi.h: In function `msi_arch_init':
include2/asm/msi.h:22: error: called object is not a function
make[3]: *** [drivers/pci/msi.o] Error 1

Something like below might fix this problem:
  if (platform_msi_init) {
      ia64_mv_msi_init_t *fn = platform_msi_init;
      return (*fn)();
  }

Thanks,
-- 
Jun'ichi Nomura, NEC Solutions (America), Inc.
