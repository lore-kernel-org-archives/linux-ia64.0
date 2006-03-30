From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 30 Mar 2006 15:13:15 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <442BF58B.7080100@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------080900060105020700010605"
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------080900060105020700010605
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed

Please have a look at this patch that applies after the yours.
I hope I have not forgotten anything.

Some notes:

I do not add ".nta"-s because:
- there is no atomic operation as in the dirty bit handler
- we re-read the probably unmodified data - the L1D cache can help

".bias" is out question

Thanks,

Zoltan

--------------080900060105020700010605
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="ivt.diff"
Content-Disposition: inline;
 filename="ivt.diff"

--- save/arch/ia64/kernel/ivt.S	2006-03-30 16:19:18.000000000 +0200
+++ linux-2.6.16/arch/ia64/kernel/ivt.S	2006-03-30 17:03:56.000000000 +0200
@@ -197,11 +197,12 @@ ENTRY(vhpt_miss)
 	;;
 #ifdef CONFIG_SMP
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
-	 * cannot possibly affect the following loads:
+	 * We make sure the visibility of itc.* to generated purges (like ptc.ga)
+	 * before we re-read the *pgd ... PTE.
+	 * Having itc.i-d a new translation, there is no need for srlz.i, the rfi below
+	 * will do the serialization.
 	 */
-	dv_serialize_data
-
+(p7)	srlz.d
 	/*
 	 * Re-check pagetable entry.  If they changed, we may have received a ptc.g
 	 * between reading the pagetable and the "itc".  If so, flush the entry we
@@ -266,11 +267,11 @@ ENTRY(itlb_miss)
 	;;
 #ifdef CONFIG_SMP
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
-	 * cannot possibly affect the following loads:
+	 * We make sure the visibility of itc.i to generated purges (like ptc.ga)
+	 * before we re-read the PTE.
+	 * There is no need for srlz.i, the rfi below will do the serialization.
 	 */
-	dv_serialize_data
-
+	srlz.d
 	ld8 r19=[r17]				// read *pte again and see if same
 	mov r20=PAGE_SHIFT<<2			// setup page size for purge
 	;;
@@ -310,11 +311,10 @@ dtlb_fault:
 	;;
 #ifdef CONFIG_SMP
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
-	 * cannot possibly affect the following loads:
+	 * We make sure the visibility of itc.d to generated purges (like ptc.ga)
+	 * before we re-read the PTE.
 	 */
-	dv_serialize_data
-
+	srlz.d
 	ld8 r19=[r17]				// read *pte again and see if same
 	mov r20=PAGE_SHIFT<<2			// setup page size for purge
 	;;

--------------080900060105020700010605--
