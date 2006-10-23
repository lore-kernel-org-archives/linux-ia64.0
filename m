From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 23 Oct 2006 21:00:51 +0000
Subject: printk_clock() patch breaks sn2 arch
Message-Id: <Pine.LNX.4.64.0610231354470.32322@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At the mininum we need to have a declaration of the ia64_timestamp 
function otherwise ia64 sn2 does not even compile.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc2-mm2/include/asm-ia64/timex.h
=================================--- linux-2.6.19-rc2-mm2.orig/include/asm-ia64/timex.h	2006-10-13 11:25:04.000000000 -0500
+++ linux-2.6.19-rc2-mm2/include/asm-ia64/timex.h	2006-10-23 15:48:05.565981377 -0500
@@ -39,4 +39,6 @@ get_cycles (void)
 	return ret;
 }
 
+extern unsigned long long (*ia64_timestamp_clock)(void);
+
 #endif /* _ASM_IA64_TIMEX_H */
