From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Thu, 21 Feb 2008 23:47:10 +0000
Subject: Re: [PATCH 13/28] ia64/xen: introduce xen hypercall routines necessary
Message-Id: <47BE0D7E.7080301@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

yamahata@valinux.co.jp wrote:
> +static inline unsigned long
> +HYPERVISOR_machtophys(unsigned long mfn)
> +{
> +	unsigned long ret = mfn;
> +	if (is_running_on_xen())
>   

Do you often call hypercalls when not booting under Xen?  It seems to me 
this check should have already been done at a higher layer, and it 
needn't be repeated here.

> +		ret = __HYPERVISOR_machtophys(mfn);
> +	return ret;
> +}

    J
