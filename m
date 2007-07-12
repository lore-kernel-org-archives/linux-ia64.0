From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 12 Jul 2007 22:33:06 +0000
Subject: RE: [RFC][PATCH] fsys_gettimeofday leaps days if it runs with nojitter
Message-Id: <617E1C2C70743745A92448908E030B2A01EA59F9@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <468CA2D6.40204@jp.fujitsu.com>
In-Reply-To: <468CA2D6.40204@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > I'm guessing here ... I haven't cross-checked with the architects.
>
> I'll be glad if we can get a comment from Intel's architects.

I talked this through with an architect, and I'm right.  In the
sequence:

	ld4.acq  rM = [rN]
	;;
	mov rP = ar.itc

there are no dependencies, so the read of ar.itc can occur
"IMMEDIATELY after the load issues".

Consuming the result of the load in between will create a
dependency ... so the timestamp will be taken as we want it,
after the load.

So I can apply this patch (moving the "and r28 = ~1,r28").

What other time patches are you still pushing?  The time
interpolator changes that were predicted still look like
they are pending somewhere (kernel/timer.c hasn't been
changed).

-Tony
