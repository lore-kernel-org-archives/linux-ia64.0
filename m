From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 16 Jul 2007 21:33:57 +0000
Subject: RE: [PATCH 1/2] ia64 clocksource
Message-Id: <617E1C2C70743745A92448908E030B2A01EDC36D@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070714002509.GJ2317@localhost>
In-Reply-To: <20070714002509.GJ2317@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Half a dozen whines from GIT about whitespace (irrelevent
paces followed by a <TAB>).  Here are the lines:

+        	/* Sort out mult/shift values: */
+        	clocksource_register(&clocksource_itc);
+#define	write_counter(V, MC) 	writel(V, MC)
+        	hpet_mctr = (void __iomem *)&hpetp->hp_hpet->hpet_mc;
+        	clocksource_hpet.mult = clocksource_hz2mult(hpetp->hp_tick_freq,
+        	clocksource_register(&clocksource_hpet);

Part 2 of the patch should also delete Documentation/time_interpolators.txt

Seto-san: The fsys.S changes need some close review and you've
been looking at this code recently ... so you are declared an
independent expert :-)  The problem that you found with out of
order read of the xtime_lock.sequence (now gtod_lock.sequence)
is probably alive and well in this code too (even though the read
of ar.itc is later, there is no consumption or r28 before we do
so).


On the subject of whether to push into 2.6.23 or cook in -mm until
2.6.24 ... I'm not sure how much benefit we'd get from the delay.
Anyone want to stand up and be counted as running serious testing
on -mm kernels on ia64?  I fear that the amount of extra testing
that we'd get is really quite small.  2.6.23-rc1 is only a week away,
and this code is very subtle in places ... I'm nervous about this.

-Tony
