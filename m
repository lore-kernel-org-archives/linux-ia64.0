From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Tue, 24 Jul 2007 14:28:45 +0000
Subject: Re: panic from vector domain patch (was RE: Linus' tree broken?)
Message-Id: <1185287325.4000.22.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <1185239265.19353.6.camel@phobos>
In-Reply-To: <1185239265.19353.6.camel@phobos>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yasuaki,

> > Oops, I forgot to consider assign_irq_vector(AUTO_ASSIGN) case.
> > I'm writing bug fix patch now. Wait a moment.
> 
> Unfortunately, I don't have any ski simulator environment. I attached
> the bug fix patch. Could you try this patch?
> 

I tried your patch on my ski environment, and I confirmed it fixes
the "Out of interrupt vectors" problem reported by Peter Chubb.

Thanks,
Kenji Kaneshige


2007-07-24 (火) の 22:09 +0900 に Yasuaki Ishimatsu さんは書きました:
> Hi Doug,
> 
> Yasuaki Ishimatsu wrote:
> > Hi Doug,
> >
> > Doug Chapman wrote:
> >> On Mon, 2007-07-23 at 13:42 -0700, Luck, Tony wrote:
> >>>>> Could be, but it sounds like there's something fishy in the current
> >>>>> tree - Doug Chapman is having problems as well, presumably on zx1 boxes.
> >>>> I am seeing the panic on HP zx1 and zx2 systems.  Currently doing a git
> >>>> bisect to narrow it down.
> >>> 2.6.23-rc1 booted OK on my rx2620.  On the zx2000 too (though X is currently
> >>> behaving weirdly, I think that might be some other issue though).
> >>>
> >>> -Tony
> >> Through the magic of git-bisect I have narrowed it down to this commit
> >> (although I don't know why):
> >>
> >> commit 4994be1b3fe9120c88022ff5c0c33f6312b17adb
> >> Author: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> >> Date:   Tue Jul 17 21:22:33 2007 +0900
> >>
> >>     [IA64] Add support for vector domain
> >>
> >>     Add fundamental support for multiple vector domain. There still exists
> >>     only one vector domain even with this patch. IRQ migration across
> >>     domain is not supported yet by this patch.
> >>
> >>     Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
> >>     Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> >>     Signed-off-by: Tony Luck <tony.luck@intel.com>
> >>
> >>
> >>
> >> As far as why I see this and so far others have not I have 2 guesses.
> >> It could be related to firmware version (I have all my systems with
> >> the latest available version) or, it could be the version of elilo
> >> (perhaps more of a longshot).
> >>
> >> Or, could be my .config file (ok, now that I think of it that may be
> >> more likely).  Attaching my .config here.  This is a custom config
> >> that started out as the fedora 7 .config but I have made some changes
> >> over time.
> >
> > Oops, I forgot to consider assign_irq_vector(AUTO_ASSIGN) case.
> > I'm writing bug fix patch now. Wait a moment.
> 
> Unfortunately, I don't have any ski simulator environment. I attached
> the bug fix patch. Could you try this patch?
> 
> Thanks,
> Yasuaki Ishimatsu
> 
> 
> 
> This change fixes a panic when assign_irq_vector(irq) is called with
> irq = AUTO_ASSIGN.
> 
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
>  arch/ia64/kernel/irq_ia64.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6.23-rc1/arch/ia64/kernel/irq_ia64.c
> =================================> --- linux-2.6.23-rc1.orig/arch/ia64/kernel/irq_ia64.c	2007-07-24 16:08:32.000000000 +0900
> +++ linux-2.6.23-rc1/arch/ia64/kernel/irq_ia64.c	2007-07-24 16:19:46.000000000 +0900
> @@ -212,9 +212,6 @@
>  	vector = -ENOSPC;
> 
>  	spin_lock_irqsave(&vector_lock, flags);
> -	if (irq < 0) {
> -		goto out;
> -	}
>  	for_each_online_cpu(cpu) {
>  		domain = vector_allocation_domain(cpu);
>  		vector = find_unassigned_vector(domain);
> @@ -223,6 +220,8 @@
>  	}
>  	if (vector < 0)
>  		goto out;
> +	if (irq = AUTO_ASSIGN)
> +		irq = vector;
>  	BUG_ON(__bind_irq_vector(irq, vector, domain));
>   out:
>  	spin_unlock_irqrestore(&vector_lock, flags);

