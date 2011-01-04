From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 04 Jan 2011 22:26:43 +0000
Subject: RE: ia64 lockdep patch prepared for linux 2.6.38
Message-Id: <987664A83D2D224EAE907B061CE93D530193F67AC0@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AANLkTimJ3au7G+kUA1CjPxzySGnuaPRVJgssjbXSeSu+@mail.gmail.com>
In-Reply-To: <AANLkTimJ3au7G+kUA1CjPxzySGnuaPRVJgssjbXSeSu+@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Oh....then would you like to create a new branch for stuff' like lockdep?
> It would be very helpful for me.

I'm not quite sure how a branch for which you are the only
real user will help.  Unless you know of some other people
waiting to jump on and help once they see this patch in a
tree?

>I noticed that there is a Macro in INIT_TASK that has softirqs_enable
>initialized to 1. (by default it is 0 ,which is copied from
>INIT_TASK). Both softirqs_enabled and hardirqs_enabled must be
>explicitly initialized to 1 in relavent kenrel paths by the lockdep
>and irqflag trace patch. I still need to find a right place to do
>that.
>

Why is ia64 different ... it seems odd that other architectures
haven't run in to this.  If ia64 is the only one that needs it,
then it should be in some ia64 specific place - or failing that
done in a way that gives me confidence that it is a nop on the
other architectures (so I don't get blamed for breaking them).

Same argument for MAX_LOCKDEP_KEYS_BITS which you reduce from
13 to 12 (percpu space is limited on ia64 - but that doesn't
justify reducing this for everyone else).  Is there some
ia64 arch file in which we could define this, and then make
the generic linux/lockdep.h file have

#ifndef MAX_LOCKDEP_KEYS_BITS
#define MAX_LOCKDEP_KEYS_BITS 13
#endif

???

> Do you want me to fix this as the first step to merge?

Yes - we need to have cleaner changes to the generic files
that are part of this patch first.

-Tony
