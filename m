From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 08 Sep 2004 23:23:01 +0000
Subject: Re: Timer patch V8
Message-Id: <Pine.LNX.4.58.0409081620340.27229@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408092115500.22817@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408092115500.22817@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sorry. I was too superficial when looking at this issue. The following
patch makes the hpet driver build again but I do not have a machine here
that would allow me to test this. Could you verify that this works and get
back to me?

Index: linux-2.6.9-rc1/drivers/char/hpet.c
=================================--- linux-2.6.9-rc1.orig/drivers/char/hpet.c	2004-09-07 18:37:00.000000000 -0700
+++ linux-2.6.9-rc1/drivers/char/hpet.c	2004-09-08 16:17:57.000000000 -0700
@@ -664,8 +664,7 @@

 static struct time_interpolator hpet_interpolator = {
 	.source = TIME_SOURCE_MMIO64,
-	.shift = 10,
-	.addr = MC
+	.shift = 10
 };

 #endif
@@ -953,11 +952,10 @@
 			struct hpet *hpet;

 			hpet = hpets->hp_hpet;
-			hpet_cycles_per_sec = hpet_time_div(hpets->hp_period);
-			hpet_interpolator.frequency = hpet_cycles_per_sec;
-			hpet_interpolator.drift = hpet_cycles_per_sec *
+			hpet_interpolator.addr = &hpets->hp_hpet->hpet_mc;
+			hpet_interpolator.frequency = hpet_time_div(hpets->hp_period);
+			hpet_interpolator.drift = hpet_interpolator.frequency *
 			    HPET_DRIFT / 1000000;
-			hpet_nsecs_per_cycle = 1000000000 / hpet_cycles_per_sec;
 			register_time_interpolator(&hpet_interpolator);
 		}
 #endif
