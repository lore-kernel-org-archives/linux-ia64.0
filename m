From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 09 Feb 2006 06:43:05 +0000
Subject: [PATCH] mca_drv: Add minstate validation
Message-Id: <43EAE479.4050606@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

MCA driver can cause panic if kernel gets a state info with no minstate.
This patch adds minstate validation before handling it.

signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

-----

  arch/ia64/kernel/mca_drv.c |    3 +++
  1 files changed, 3 insertions(+)

Index: linux-2.6.16-rc2/arch/ia64/kernel/mca_drv.c
=================================--- linux-2.6.16-rc2.orig/arch/ia64/kernel/mca_drv.c	2006-02-08 13:03:49.000000000 +0900
+++ linux-2.6.16-rc2/arch/ia64/kernel/mca_drv.c	2006-02-08 15:24:09.000000000 +0900
@@ -437,6 +437,9 @@
  	 *    the process not have any locks of kernel.
  	 */

+	/* Is minstate valid? */
+	if (!peidx_bottom(peidx) || !(peidx_bottom(peidx)->valid.minstate))
+		return 0;
  	psr1 =(struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_ipsr);

  	/*


