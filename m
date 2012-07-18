From: Fengguang Wu <fengguang.wu@intel.com>
Date: Wed, 18 Jul 2012 02:29:15 +0000
Subject: Re: ia64 build errors
Message-Id: <20120718022915.GA7797@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120717123233.GA17001@localhost>
In-Reply-To: <20120717123233.GA17001@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 18, 2012 at 05:35:38AM +0800, Luck, Tony wrote:
> > I've kicked off IA64 build tests on a native IA64 box and the test
> > kconfigs are:
> >
>  > ia64-allmodconfig
>  > ia64-allnoconfig
> >  ia64-defconfig
> 
> These are all good. Thanks for adding to your testbuild farm.

You are welcome!

I just added another alldefconfig and it works fine :)

> >  ia64-randconfig-h001
> > ...
> 
> ia64 hasn't seen any real effort to resolve problems that
> show up in random configurations - so I'm not surprised
> that you found some (I might be surprised that you
> found so few!)
> 
> I'm not quite sure where to go with these reports though.
> It looks like the first was from a CONFIG_PRINTK=n kernel.
> This isn't ever going to be a useful option for ia64. I presume
> it is there to shave down the size of the kernel by a few hundred
> bytes on embedded systems ... but with systems starting at
> 32GB ... this is never going to be significant for ia64. Also mission
> critical systems will always choose better diagnostics over
> saving some small amount of memory.
> 
> So should I juggle header include lines to fix this non-problem?
> Should I make it go away with a "select PRINTK" line in
> arch/ia64/Kconfig?
> Or just tell you that I'm not that into randconfig?

Fair enough. My thought is there will be inevitably some initial
enabling pain for randconfig errors. However once done, the system
will be catching new errors which will most likely be introduced by
random community developers who will be notified to fix the error.
You may not even notice that things get broken and fixed again :)

Anyway, let's focus on the regular configs for now: when removing the
randconfig tests, only the IA64_TASK_SIZE error remains in allmodconfig.

Thanks,
Fengguang
