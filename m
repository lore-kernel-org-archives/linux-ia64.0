From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 12 Mar 2006 17:10:59 +0000
Subject: [patch 5/6] add init declaration - nolwsys
Message-Id: <200603121710.k2CHAvg10261@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add __initdata to nolwsys.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./arch/ia64/mm/init.c.orig	2006-03-12 01:37:21.768175423 -0800
+++ ./arch/ia64/mm/init.c	2006-03-12 01:37:38.178331472 -0800
@@ -556,7 +556,7 @@ count_reserved_pages (u64 start, u64 end
  * purposes.
  */
 
-static int nolwsys;
+static int nolwsys __initdata;
 
 static int __init
 nolwsys_setup (char *s)


