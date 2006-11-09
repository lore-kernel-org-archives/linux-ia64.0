From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 09 Nov 2006 00:29:25 +0000
Subject: [patch] tidy up return value of ip_fast_csum
Message-Id: <000101c70396$1ce44c50$ff0da8c0@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While working on implementing csum_ipv6_magic, I noticed that current version of ip_fast_csum will potentially return bits above
"unsigned short" as 1.  While no
harm is done right now because all call sites will chop off the upper bits when
it uses the return value.  However, this is still dangerous and buggy.  Here is
a patch to enforce that the function really returns unsigned short in the native
register format.

The fix is free as there are plenty open slot to add one more asm instruction.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./arch/ia64/lib/ip_fast_csum.S.orig	2006-11-08 17:09:36.000000000 -0800
+++ ./arch/ia64/lib/ip_fast_csum.S	2006-11-08 17:10:04.000000000 -0800
@@ -68,8 +68,9 @@ GLOBAL_ENTRY(ip_fast_csum)
 	zxt2	r20=r20
 	;;
 	add	r20=ret0,r20
+	mov	r9=0xffff
 	;;
-	andcm	ret0=-1,r20
+	andcm	ret0=r9,r20
 	.restore sp		// reset frame state
 	br.ret.sptk.many b0
 	;;
