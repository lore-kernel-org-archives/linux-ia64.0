From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 01 Sep 2005 16:43:08 +0000
Subject: RE: testing mca/init patch
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F044B014B@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508312343.j7VNhFOZ012157@agluck-lia64.sc.intel.com>
In-Reply-To: <200508312343.j7VNhFOZ012157@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith wrote:
>That delay is coming from your SAL, nothing I can do about it.
>
 ...
>This is wrong.  The slave INIT handler was not invoked when the monarch
>was delivered, instead the slave events were delivered _after_ the
>monarch returned to the interrupted context.  It works for me on SGI's
>SAL, all the cpus enter INIT at the same time, without any noticeable
>delay.  There is no delay nor lockout in the INIT handler code before
>it gets to the first printk, so all the delay and out of order
>execution has to be coming from your SAL.
 ...
>Because all 4 cpus are driven as slaves.  All the slaves are waiting
>for the monarch to arrive.  All of the above tells me that the OS code
>is working fine, SAL is not.

That sounds all too plausible :-(

I'll track down some SAL people ask ask them what is going on.

-Tony

