From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Tue, 27 Apr 2004 13:19:26 +0000
Subject: RE: [PATCH] bug w/ shared interrupts
Message-Id: <MDEEKOKJPMPMKGHIFAMAMEPMDNAA.kaneshige.kenji@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1082989740.15656.20.camel@localhost>
In-Reply-To: <1082989740.15656.20.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I misunderstood what you were saying.
Please ignore my previous mail.

Thanks,
Kenji Kaneshige


> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Kenji Kaneshige
> Sent: Tuesday, April 27, 2004 8:57 PM
> To: Alex Williamson; linux-ia64
> Subject: RE: [PATCH] bug w/ shared interrupts
> 
> 
> Hi,
> 
> I don't know whether you are referring to my patch. But if so,
> please try a following patch. The patch for sharing vector I sent
> before contains a bug and I think this might cause a similar problem.
> 
> Thanks,
> Kenji Kaneshige
> 
> 
> This is a patch to fix the following bug:
> 
> Register_intr() changes pin->low32 even when it overrides the
> interrupt info. This destroys the value of pin->low32 which is already
> set by set_rte() or other staffs.
> 
> This patch is against linux-2.6.6-rc2 with share_vector.patch applied.
> 
> 
> ---
> 
>  linux-2.6.6-rc2-kanesige/arch/ia64/kernel/iosapic.c |    1 -
>  1 files changed, 1 deletion(-)
> 
> diff -puN arch/ia64/kernel/iosapic.c~share_vector_bugfix
> arch/ia64/kernel/iosapic.c
> --- linux-2.6.6-rc2/arch/ia64/kernel/iosapic.c~share_vector_bugfix
> 2004-04-27 18:12:56.000000000 +0900
> +++ linux-2.6.6-rc2-kanesige/arch/ia64/kernel/iosapic.c	2004-04-27
> 18:12:56.000000000 +0900
> @@ -605,7 +605,6 @@ register_intr (unsigned int gsi, int vec
>  		pin->polarity = polarity;
>  		pin->addr     = iosapic_address;
>  		pin->gsi_base = gsi_base;
> -		pin->low32    = IOSAPIC_MASK;
>  		iosapic_intr_info[vector].dmode   = delivery;
>  		iosapic_intr_info[vector].trigger = trigger;
>  		iosapic_intr_info[vector].type    = type;
> 
> _
> 
