From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Wed, 18 Jul 2007 06:47:34 +0000
Subject: Re: [PATCH take3 0/12] Support vector domain on ia64
Message-Id: <469DB786.1080603@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <469CB3FA.7010301@jp.fujitsu.com>
In-Reply-To: <469CB3FA.7010301@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

Luck, Tony wrote:
> Getting close now.  New (I think it's new, I didn't notice it last time, but I may have
> missed it in the other build noise)  concern while compiling this version was the warning:
>
>   arch/ia64/kernel/iosapic.c:597: warning: 'iosapic_free_rte' defined but not used
>
> This isn't spurious, the only call to iosapic_free_rte() has been removed, but there
> is still a call to iosapic_alloc_rte() ... which means we must have a memory leak.

I did it on purpose (and gave the warning a miss...) and I consider
iosapic_free_rte() is no longer needed.

I decided to remain iosapic_rte_info to keep gsi-to-irq binding
after device disable. Indeed it needs some extra memory, but it
is only "sizeof(iosapic_rte_info) * <the number of removed devices>"
bytes and has no memory leak becasue re-enabled devices use the
iosapic_rte_info which they used before disabling.

Here is a iosapic_free_rte() removal patch which remove the warning
message and can be applied after 12/12.

Thanks,
Yasuaki Ishimatsu



Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

 arch/ia64/kernel/iosapic.c |    8 --------
 1 files changed, 8 deletions(-)

Index: linux-2.6.22/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.22.orig/arch/ia64/kernel/iosapic.c	2007-07-17 12:09:47.000000000 +0900
+++ linux-2.6.22/arch/ia64/kernel/iosapic.c	2007-07-18 11:59:33.000000000 +0900
@@ -593,14 +593,6 @@ static struct iosapic_rte_info *iosapic_
 	return rte;
 }

-static void iosapic_free_rte (struct iosapic_rte_info *rte)
-{
-	if (rte->flags & RTE_PREALLOCATED)
-		list_add_tail(&rte->rte_list, &free_rte_list);
-	else
-		kfree(rte);
-}
-
 static inline int irq_is_shared (int irq)
 {
 	return (iosapic_intr_info[irq].count > 1);

