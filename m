From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Fri, 18 Jul 2008 18:25:31 +0000
Subject: Re: [PATCH 24/29] ia64/pv_ops/xen: implement xen pv_time_ops.
Message-Id: <4880E01B.6060902@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <12162606623288-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12162606623288-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>
> ITC is never synchronized between cpus.  On some systems all processor ITC
> may be driven from the same clock ... so an "offset from absolute system time"
> would work on those systems. But on others the ITC on different processors
> may be driven from different crystals, so the *rate* may be different. The
> difference may be small if the crystals have the same nominal frequency, but
> in the worst case the rates may be readically different (e.g. in some SGI
> systems ~1.2GHz on some cpus and ~1.6GHz on others).
>   

OK.  The patch in question has code like:

+	if (!time_after(delta_itm + new_itm, ia64_get_itc()))
+		stolentick = ia64_get_itc() - new_itm;
+
+	do_div(stolentick, NS_PER_TICK);


Which makes me assume that ia64_get_itc() is returning nanoseconds; does 
it do the adjustment from the itc's actual rate to nanoseconds?  Could 
it also apply an offset?

    J
