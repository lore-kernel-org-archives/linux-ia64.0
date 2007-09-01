From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 01 Sep 2007 10:14:38 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A024F3C01@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Having looked closer, it looks like the magic actually disables some 
> broken code from happening on other architectures.

Yes.  The drivers/char/hpet.c clocksource code was added for ia64 as
part of the switch from the time interpolator to the generic clock
code ... but the patch had languished for a long time, and by the time
it was resurrected, i386 and x86_64 had added their own arch specific
code ... which didn't get noticed until the "double hpet" bug report
was logged.

> However, why was it done in that illogical manner?

Too much LDS back in the sixties?  It looked very weird, but in a
cute sort of way ... and I though the lifetime of the code was likely
to be short (since this code is screming to be merged into a single
version used by any arch with HPET) ... so I pushed it in.  Sorry.
Your patch is much better.

Here's a commit comment for your patch:

The HPET clocksource code in drivers/char/hpet.c should not be
registered on anything except ia64 (as it is known to cause problems
on x86_64, and perhaps i386 too). Disable this code with an #ifdef
until we can merge all the hpet clocksource code.

Acked-by: Tony Luck <tony.luck@intel.com>


---
 drivers/char/hpet.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/char/hpet.c b/drivers/char/hpet.c
index 77bf4aa..7ecffc9 100644
--- a/drivers/char/hpet.c
+++ b/drivers/char/hpet.c
@@ -909,6 +909,8 @@ int hpet_alloc(struct hpet_data *hdp)
 
 	hpetp->hp_delta = hpet_calibrate(hpetp);
 
+/* This clocksource driver currently only works on ia64 */
+#ifdef CONFIG_IA64
 	if (!hpet_clocksource) {
 		hpet_mctr = (void __iomem *)&hpetp->hp_hpet->hpet_mc;
 		CLKSRC_FSYS_MMIO_SET(clocksource_hpet.fsys_mmio, hpet_mctr);
@@ -918,6 +920,7 @@ int hpet_alloc(struct hpet_data *hdp)
 		hpetp->hp_clocksource = &clocksource_hpet;
 		hpet_clocksource = &clocksource_hpet;
 	}
+#endif
 
 	return 0;
 }
