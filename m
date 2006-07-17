From: Horms <horms@verge.net.au>
Date: Mon, 17 Jul 2006 23:10:59 +0000
Subject: Re: [PATCH] panic_on_oops: remove ssleep()
Message-Id: <20060717231056.GC12463@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <31687.FP.7244@verge.net.au> <200607180027.51986.ak@suse.de>
In-Reply-To: <200607180027.51986.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Russell King <rmk@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Chris Zankel <chris@zankel.net>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, discuss@x86-64.org, linux-kernel@vger.kernel.org

On Tue, Jul 18, 2006 at 12:27:51AM +0200, Andi Kleen wrote:
> On Monday 17 July 2006 18:17, Horms wrote:
> > This patch is part of an effort to unify the panic_on_oops behaviour
> > across all architectures that implement it.
> >
> > It was pointed out to me by Andi Kleen that if an oops has occured
> > in interrupt context, then calling sleep() in the oops path will only cause
> > a panic, and that it would be really better for it not to be in the path at
> > all.
> >
> > This patch removes the ssleep() call and reworks the console message
> > accordinly.  I have a slght concern that the resulting console message is
> > too long, feedback welcome.
> 
> Keeping the delay might be actually useful so that you can see the panic
> before system reboots when reboot on panic is enabled. I would just use a loop
> of mdelays(1) with touch_nmi_watchdog/touch_softirq_watchdog()s
> inbetween.

Ok, I will look into making that happen. I agree that the pause is
quite useful.

-- 
Horms                                           
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

