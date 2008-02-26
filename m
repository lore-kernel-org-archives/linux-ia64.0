From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 26 Feb 2008 11:25:13 +0000
Subject: Re: 2.6.25-rc2-mm1 - boot hangs on ia64
Message-Id: <20080226202308.FF40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1203955017.5046.29.camel@localhost>
In-Reply-To: <1203955017.5046.29.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-ia64 <linux-ia64@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, Bob Picco <bob.picco@hp.com>, Eric Whitney <eric.whitney@hp.com>

Hi

Fujitsu machine can't boot too.
my bisect indicate git-sched.patch cause regression too.

Thanks.

> 25-rc2-mm1 is hanging early in boot on my HP ia64 numa platform.  I saw
> the "Strange hang on ia64 with CONFIG_PRINTK_TIME=y" thread on lkml:  
> 
> 	http://marc.info/?t0288396800001&r=1&w=4
> 
> However, my config does not include PRINTK_TIME=y.  In fact, hang occurs
> with ia64 defconfig as well--right after the "Loading...initrd...done"
> message.  2.6.25-rc2 boots OK.
> 
> Bisecting the broken-out series appears to indict 'git-sched.patch'.  I
> went ahead and added Ingo's patch, discussed in the "strange hang"
> thread, even tho' I hadn't enabled printk timestamps.  No effect.
> 
> Anyone else seeing this?



