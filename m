From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 25 Feb 2008 17:18:52 +0000
Subject: Re: [PATCH 03/28] ia64/xen: increase IA64_MAX_RSVD_REGIONS.
Message-Id: <200802251018.52730.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12036570474112-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12036570474112-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 21 February 2008 10:10:19 pm Isaku Yamahata wrote:
> Xenlinux/ia64 needs to reserve one more region passed from xen hypervisor
> as start info.

I don't think it's really worth adding an ifdef here to save
one struct rsvd_region (two longs).  Why not just increase
IA64_MAX_RSVD_REGIONS to 9 for everybody, and get rid of the
ifdef?

> +#ifdef CONFIG_XEN
>  #define IA64_MAX_RSVD_REGIONS 8
> +#else
> +#define IA64_MAX_RSVD_REGIONS 9
> +#endif
>  
>  struct rsvd_region {
>  	unsigned long start;	/* virtual address of beginning of element */


