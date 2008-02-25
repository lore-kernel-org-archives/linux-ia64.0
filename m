From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Date: Mon, 25 Feb 2008 15:56:57 +0000
Subject: 2.6.25-rc2-mm1 - boot hangs on ia64
Message-Id: <1203955017.5046.29.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64 <linux-ia64@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>
Cc: Bob Picco <bob.picco@hp.com>, Eric Whitney <eric.whitney@hp.com>

25-rc2-mm1 is hanging early in boot on my HP ia64 numa platform.  I saw
the "Strange hang on ia64 with CONFIG_PRINTK_TIME=y" thread on lkml:  

	http://marc.info/?t0288396800001&r=1&w=4

However, my config does not include PRINTK_TIME=y.  In fact, hang occurs
with ia64 defconfig as well--right after the "Loading...initrd...done"
message.  2.6.25-rc2 boots OK.

Bisecting the broken-out series appears to indict 'git-sched.patch'.  I
went ahead and added Ingo's patch, discussed in the "strange hang"
thread, even tho' I hadn't enabled printk timestamps.  No effect.

Anyone else seeing this?

Regards,
Lee

