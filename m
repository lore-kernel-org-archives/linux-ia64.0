From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 06 Jul 2006 17:46:37 +0000
Subject: Re: NUMA but not SMP
Message-Id: <Pine.LNX.4.64.0607061045570.24717@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A30031D@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A30031D@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 5 Jul 2006, Luck, Tony wrote:

> IA64 allows NUMA to be set without SMP ... in fact you
> end up with this when trying to build a "generic UP" kernel
> since CONFIG_IA64_GENERIC selects NUMA, and won't let you
> unselect it.
> 
> Suddenly this is a problem.  Generic UP kernel fails to build
> with an "Undefined: __inc_zone_state", which shows up because
> the __inc_zone_state function is defined inside some #if SMP
> code, but used inside some #if NUMA code in mm/vmstat.c

My fault. Does this fix it:

Index: linux-2.6/include/linux/vmstat.h
=================================--- linux-2.6.orig/include/linux/vmstat.h	2006-07-06 10:41:34.000000000 -0700
+++ linux-2.6/include/linux/vmstat.h	2006-07-06 10:45:45.000000000 -0700
@@ -186,11 +186,16 @@ static inline void __mod_zone_page_state
 	zone_page_state_add(delta, zone, item);
 }
 
+static void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
+{
+	atomic_long_inc(&zone->vm_stat[item]);
+	atomic_long_inc(&vm_stat[item]);
+}
+
 static inline void __inc_zone_page_state(struct page *page,
 			enum zone_stat_item item)
 {
-	atomic_long_inc(&page_zone(page)->vm_stat[item]);
-	atomic_long_inc(&vm_stat[item]);
+	__inc_zone_state(page_zone(page), item);
 }
 
 static inline void __dec_zone_page_state(struct page *page,
