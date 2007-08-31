From: john stultz <johnstul@us.ibm.com>
Date: Fri, 31 Aug 2007 18:46:39 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <1188585999.6479.3.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2007-08-31 at 01:37 -0700, Linus Torvalds wrote:
> 
> On Thu, 30 Aug 2007, Linus Torvalds wrote:
> > 
> > So there are two cases:
> > 
> >  - either the code is already only used on ia64, and nobody else will 
> >    care.
> > 
> >    In this case, the patch is pointless.
> > 
> >  - or it's used by others, and others *will* care, and (judging by the 
> >    probably intent of the bogus initializer) they may then die a horrible 
> >    death.
> > 
> >    In this case, the patch is actively evil, and should not have come in 
> >    through an ia64 merge.
> > 
> > In other words, either it's pointless, or it's really really bad. Please 
> > explain to me why I should pull this, especially this late in the -rc 
> > game?
> 
> Having looked closer, it looks like the magic actually disables some 
> broken code from happening on other architectures.
> 
> However, why was it done in that illogical manner?
> 
> It would appear that what you actually wanted to happen in that commit was 
> to make sure that the clocksource didn't get registered. If so, the 
> logical patch would be something like the appended instead, which would 
> disable the code that registers it the _obvious_ way, instead of 
> initializing a variable to a bad pointer and then relying on the bad 
> pointer to disable the code.
> 
> So can somebody explain to me why it was done in that really odd way? 

Sorry, that's me.  I just got smacked earlier for #ifdef's in code, so I
figured by initializing hpet_clocksource to a junk value it wouldn't get
initialized, and kept the #ifdefs outside functions. I'll agree it is
more obfuscated, and yours is much more straight forward.

Apologies, apparently I'm still learning the balance.
-john

> ---
>  drivers/char/hpet.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/char/hpet.c b/drivers/char/hpet.c
> index 77bf4aa..7ecffc9 100644
> --- a/drivers/char/hpet.c
> +++ b/drivers/char/hpet.c
> @@ -909,6 +909,8 @@ int hpet_alloc(struct hpet_data *hdp)
> 
>  	hpetp->hp_delta = hpet_calibrate(hpetp);
> 
> +/* This clocksource driver currently only works on ia64 */
> +#ifdef CONFIG_IA64
>  	if (!hpet_clocksource) {
>  		hpet_mctr = (void __iomem *)&hpetp->hp_hpet->hpet_mc;
>  		CLKSRC_FSYS_MMIO_SET(clocksource_hpet.fsys_mmio, hpet_mctr);
> @@ -918,6 +920,7 @@ int hpet_alloc(struct hpet_data *hdp)
>  		hpetp->hp_clocksource = &clocksource_hpet;
>  		hpet_clocksource = &clocksource_hpet;
>  	}
> +#endif
> 
>  	return 0;
>  }



