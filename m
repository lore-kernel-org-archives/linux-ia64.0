From: Horms <horms@verge.net.au>
Date: Wed, 07 Feb 2007 06:49:25 +0000
Subject: [PATCH] [IA64] whitespace fixes for include/asm-ia64/sal.h
Message-Id: <20070207064924.GA726@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Adrian Bunk <trivial@kernel.org>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <magnus.damm@gmail.com>

* Make use of spaces and tabs consistent
* Make long line < 80col

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/include/asm-ia64/sal.h
=================================--- linux-2.6.orig/include/asm-ia64/sal.h	2007-02-07 11:53:12.000000000 +0900
+++ linux-2.6/include/asm-ia64/sal.h	2007-02-07 12:46:57.000000000 +0900
@@ -860,12 +867,13 @@
  */
 struct sal_to_os_boot {
 	u64 rr[8];		/* Region Registers */
-	u64	br[6];		/* br0: return addr into SAL boot rendez routine */
+	u64 br[6];		/* br0:
+				 * return addr into SAL boot rendez routine */
 	u64 gr1;		/* SAL:GP */
 	u64 gr12;		/* SAL:SP */
 	u64 gr13;		/* SAL: Task Pointer */
 	u64 fpsr;
-	u64	pfs;
+	u64 pfs;
 	u64 rnat;
 	u64 unat;
 	u64 bspstore;

