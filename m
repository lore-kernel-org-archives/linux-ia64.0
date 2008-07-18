From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 18 Jul 2008 16:28:30 +0000
Subject: RE: [PATCH 24/29] ia64/pv_ops/xen: implement xen pv_time_ops.
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3065E3595@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12162606623288-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12162606623288-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> So, my understanding from looking at your patch that the itc is somewhat
> like the x86 tsc, in that it's not (necessarily) synchronized between
> cpus.  But unlike the tsc, the itc is always in nanoseconds, but you
> don't get information from Xen about the current physical cpu's offset
> from absolute system time.  And that means you have the (rather dubious
> looking) comparisons to test for large jumps in the itc which you try to
> ignore.

ITC is never synchronized between cpus.  On some systems all processor ITC
may be driven from the same clock ... so an "offset from absolute system time"
would work on those systems. But on others the ITC on different processors
may be driven from different crystals, so the *rate* may be different. The
difference may be small if the crystals have the same nominal frequency, but
in the worst case the rates may be readically different (e.g. in some SGI
systems ~1.2GHz on some cpus and ~1.6GHz on others).

-Tony
