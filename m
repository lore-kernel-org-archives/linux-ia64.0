From: Luming Yu <luming.yu@gmail.com>
Date: Tue, 04 Jan 2011 02:39:56 +0000
Subject: Re: ia64 lockdep patch prepared for linux 2.6.38
Message-Id: <AANLkTimvGFUV1ctTF+iayovuAwP6HC89=gsw+veT1w5_@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AANLkTimJ3au7G+kUA1CjPxzySGnuaPRVJgssjbXSeSu+@mail.gmail.com>
In-Reply-To: <AANLkTimJ3au7G+kUA1CjPxzySGnuaPRVJgssjbXSeSu+@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 4, 2011 at 2:18 AM, Luck, Tony <tony.luck@intel.com> wrote:
>> if you can get the patch merged into your test branch
>
> My test branch is pulled into each linux-next build ... and there
> are some generic changes at the end of your patch that I don't
> understand - but they look like they will affect other architectures.

Oh....then would you like to create a new branch for stuff' like lockdep?
It would be very helpful for me.

>
> What are INIT_{SOFT,HARD}_IRQFLAGS for? Why do we need to add them
> for ia64?

I found a lockdep warning in kernel boot where a kernel process (don't
remember if it is IDLE) is hit by the following check in copy_process
(kernel/fork.c)

#ifdef CONFIG_PROVE_LOCKING
        DEBUG_LOCKS_WARN_ON(!p->hardirqs_enabled);
        DEBUG_LOCKS_WARN_ON(!p->softirqs_enabled);
#endif

I noticed that there is a Macro in INIT_TASK that has softirqs_enable
initialized to 1. (by default it is 0 ,which is copied from
INIT_TASK). Both softirqs_enabled and hardirqs_enabled must be
explicitly initialized to 1 in relavent kenrel paths by the lockdep
and irqflag trace patch. I still need to find a right place to do
that.

Do you want me to fix this as the firs step to merge?

Thanks,
Luming
