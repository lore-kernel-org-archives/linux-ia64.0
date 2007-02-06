From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 06 Feb 2007 21:32:36 +0000
Subject: RE: [PATCH] Hook up getcpu system call for IA64
Message-Id: <617E1C2C70743745A92448908E030B2A0117C2DD@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070206000757.GA32026@linux-os.sc.intel.com>
In-Reply-To: <20070206000757.GA32026@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > getcpu system call returns cpu# and node# on which this system call
> > and its caller are running. This patch hooks up its implementation on
> > IA64.
>
> I know it's trivial to wire up sys_getcpu, but please take this seriously,
> it should be implemented as assembly fsys call.

We did look at whether it was worth doing as a fast syscall.

How often will applications call getcpu() ... I hope that they aren't doing
it hundreds of thousands of times per second (scheduler won't re-assign to
a different cpu more often than every few milli-seconds, so it is pointless
to call that often).

"Slow" syscall is ~1.5us ... which should be in the noise for what I think
is the fastest rate at which applications may call it.

Do you have some example application scenarios where you believe the
rate will be high enough to make a difference?

-Tony
