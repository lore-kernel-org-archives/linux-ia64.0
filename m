From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 17 Jul 2012 21:35:38 +0000
Subject: RE: ia64 build errors
Message-Id: <3908561D78D1C84285E8C5FCA982C28F1936AE99@ORSMSX104.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120717123233.GA17001@localhost>
In-Reply-To: <20120717123233.GA17001@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I've kicked off IA64 build tests on a native IA64 box and the test
> kconfigs are:
>
 > ia64-allmodconfig
 > ia64-allnoconfig
>  ia64-defconfig

These are all good. Thanks for adding to your testbuild farm.

>  ia64-randconfig-h001
> ...

ia64 hasn't seen any real effort to resolve problems that
show up in random configurations - so I'm not surprised
that you found some (I might be surprised that you
found so few!)

I'm not quite sure where to go with these reports though.
It looks like the first was from a CONFIG_PRINTK=n kernel.
This isn't ever going to be a useful option for ia64. I presume
it is there to shave down the size of the kernel by a few hundred
bytes on embedded systems ... but with systems starting at
32GB ... this is never going to be significant for ia64. Also mission
critical systems will always choose better diagnostics over
saving some small amount of memory.

So should I juggle header include lines to fix this non-problem?
Should I make it go away with a "select PRINTK" line in
arch/ia64/Kconfig?
Or just tell you that I'm not that into randconfig?

-Tony
