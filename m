From: Martin Michlmayr <tbm@cyrius.com>
Date: Tue, 15 May 2007 16:42:02 +0000
Subject: Fix section conflict of ia64_mlogbuf_finish
Message-Id: <20070515164202.GA19839@deprecation.cyrius.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Building with GCC 4.2, I get the following error:

  CC      arch/ia64/kernel/mca.o
arch/ia64/kernel/mca.c:275: error: __ksymtab_ia64_mlogbuf_finish causes a section type conflict

This is because ia64_mlogbuf_finish is both declared static and exported.

Signed-off-by: Martin Michlmayr <tbm@cyrius.com>

--- a/arch/ia64/kernel/mca.c~	2007-05-15 16:15:50.000000000 +0000
+++ b/arch/ia64/kernel/mca.c	2007-05-15 16:27:46.985701032 +0000
@@ -254,7 +254,7 @@
  * invoked, long-wait rendezvous etc.)
  *  NOTE: this should be called from monarch.
  */
-static void ia64_mlogbuf_finish(int wait)
+void ia64_mlogbuf_finish(int wait)
 {
 	BREAK_LOGLEVEL(console_loglevel);
 

-- 
Martin Michlmayr
http://www.cyrius.com/
