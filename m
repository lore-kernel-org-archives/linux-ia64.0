From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 00:50:08 +0000
Subject: syscall improvement patch [2/12]
Message-Id: <200503240050.j2O0o8JW022268@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64: Use dynamic prediction for RSE-clearing branches.

This by itself is good for a 1-2 cycle speed up.  Effect is bigger
when combined with the later patches.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/entry.S 1.83 vs edited ==--- 1.83/arch/ia64/kernel/entry.S	2005-03-23 11:50:09 -08:00
+++ edited/arch/ia64/kernel/entry.S	2005-03-23 11:50:30 -08:00
@@ -1012,14 +1012,14 @@
 	mov loc5=0
 	mov loc6=0
 	mov loc7=0
-(pRecurse) br.call.sptk.few b0=rse_clear_invalid
+(pRecurse) br.call.dptk.few b0=rse_clear_invalid
 	;;
 	mov loc8=0
 	mov loc9=0
 	cmp.ne pReturn,p0=r0,in1	// if recursion count != 0, we need to do a br.ret
 	mov loc10=0
 	mov loc11=0
-(pReturn) br.ret.sptk.many b0
+(pReturn) br.ret.dptk.many b0
 #endif /* !CONFIG_ITANIUM */
 #	undef pRecurse
 #	undef pReturn
