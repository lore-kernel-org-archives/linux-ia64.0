From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 13 Oct 2003 23:33:48 +0000
Subject: [PATCH 2.4 and 2.6] Another mca sub-patch
Message-Id: <marc-linux-ia64-106608825201386@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The definition of the pal_process_state_info_s structure
misses out some useful pieces (e.g. the "mi" bit which indicates
whether we should call PAL_MC_ERROR_INFO to get more details).

Worse yet, some of the bits are in the wrong places (cc/tc/bc).

See Volume 2 of "Intel Itanium Architecture Software Developer's
Manual".  (In the Rev 2.1 October 2002 edition, p. 2:268 and 2:276).

-Tony

diff -ru temp/include/asm-ia64/pal.h mca/include/asm-ia64/pal.h
--- temp/include/asm-ia64/pal.h	2003-09-08 12:50:12.000000000 -0700
+++ mca/include/asm-ia64/pal.h	2003-10-03 11:47:57.000000000 -0700
@@ -405,10 +405,11 @@
 						 * generated.
 						 * (Trap Lost )
 						 */
-			op		: 3,	/* Operation that
-						 * caused the machine
-						 * check
+			mi		: 1,	/* More information available
+						 * call PAL_MC_ERROR_INFO
 						 */
+			pi		: 1,	/* Precise instruction pointer */
+			pm		: 1,	/* Precise min-state save area */
 
 			dy		: 1,	/* Processor dynamic
 						 * state valid
@@ -450,11 +451,12 @@
 						 * by the processor
 						 */
 
-			reserved2	: 12,
+			reserved2	: 11,
 			cc		: 1,	/* Cache check */
 			tc		: 1,	/* TLB check */
 			bc		: 1,	/* Bus check */
-			uc		: 1;	/* Unknown check */
+			rc		: 1,	/* Register file check */
+			uc		: 1;	/* Uarch check */
 
 } pal_processor_state_info_t;
 
