From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 09 Dec 2005 17:46:15 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <200512091046.15976.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 09 December 2005 10:11 am, Robin Holt wrote:
> Prarit, I don't think your patch catches all the cases.  Try
> this one.
> 
> Index: linux-2.6/arch/ia64/sn/kernel/sn2/sn_hwperf.c
> =================================> --- linux-2.6.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-11-21 20:05:40.000000000 -0600
> +++ linux-2.6/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-12-09 10:53:19.159948227 -0600
> @@ -973,6 +973,9 @@ static int __devinit sn_hwperf_misc_regi
>  {
>  	int e;
>  
> +	if (!ia64_platform_is("sn2"))
> +		return -ENODEV;

I'm not thrilled about this approach.

I'd *like* to be able to assume that "changes in arch/ia64/sn/* clearly
don't affect non-SN platforms".  But this style breaks that.  Every ia64
box calls all these SN init functions, and if somebody forgets the
ia64_platform_is("sn2") check, bad things will happen.

I'd like it a whole lot better if all these initialization-type things
could be hidden inside sn_setup() or some other machine vector.

