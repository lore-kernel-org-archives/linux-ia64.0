From: Keith Owens <kaos@sgi.com>
Date: Fri, 11 Jun 2004 14:19:24 +0000
Subject: [patch 2.6.7-rc3] Remove warnings when unwind debug is turned on
Message-Id: <18662.1086963564@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Turning on UNW_DEBUG generates warnings for incorrect number of
parameters for formats and several cases of "suggest explicit braces to
avoid ambiguous `else'", because UNW_DPRINT contains an if statement.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/kernel/unwind.c
=================================--- linux.orig/arch/ia64/kernel/unwind.c	Sat Jun 12 00:08:24 2004
+++ linux/arch/ia64/kernel/unwind.c	Sat Jun 12 00:13:56 2004
@@ -395,9 +395,10 @@ unw_access_gr (struct unw_frame_info *in
 	}
 
 	if (write) {
-		if (read_only(addr))
-			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n");
-		else {
+		if (read_only(addr)) {
+			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n",
+				__FUNCTION__);
+		} else {
 			*addr = *val;
 			if (*nat)
 				*nat_addr |= nat_mask;
@@ -442,9 +443,10 @@ unw_access_br (struct unw_frame_info *in
 		return -1;
 	}
 	if (write)
-		if (read_only(addr))
-			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n");
-		else
+		if (read_only(addr)) {
+			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n",
+				__FUNCTION__);
+		} else
 			*addr = *val;
 	else
 		*val = *addr;
@@ -490,9 +492,10 @@ unw_access_fr (struct unw_frame_info *in
 	}
 
 	if (write)
-		if (read_only(addr))
-			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n");
-		else
+		if (read_only(addr)) {
+			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n",
+				__FUNCTION__);
+		} else
 			*addr = *val;
 	else
 		*val = *addr;
@@ -586,9 +589,10 @@ unw_access_ar (struct unw_frame_info *in
 	}
 
 	if (write) {
-		if (read_only(addr))
-			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n");
-		else
+		if (read_only(addr)) {
+			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n",
+				__FUNCTION__);
+		} else
 			*addr = *val;
 	} else
 		*val = *addr;
@@ -606,9 +610,10 @@ unw_access_pr (struct unw_frame_info *in
 		addr = &info->sw->pr;
 
 	if (write) {
-		if (read_only(addr))
-			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n");
-		else
+		if (read_only(addr)) {
+			UNW_DPRINT(0, "unwind.%s: ignoring attempt to write read-only location\n",
+				__FUNCTION__);
+		} else
 			*addr = *val;
 	} else
 		*val = *addr;

