From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 12 Nov 2004 05:42:43 +0000
Subject: scary GCC bug (causes hpoj v0.91 crash)
Message-Id: <200411120542.iAC5ghk3008313@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is a rather scary and longstanding GCC bug [1] which causes
instant crashes if a program defines a struct with function-pointers
and that structure happens to be "packed".  Why anybody would want to
do such a thing is beyond me, but suffice it to say that hpoj v0.91 is
doing precisely that.  The current Debian/sarge package for hpoj is
definitely affected (any attempt to scan an image results in an
instant crash).

A patch to work around the problem is attached.

Perhaps the hpoj developers can tell us whether it was really
intentional to have the #pragma pack(1) span all of <stdlib.h> and
<xform.h>?

Thanks,

	--david

[1] http://gcc.gnu.org/bugzilla/show_bug.cgi?id44

--- hpoj-0.91/include/hpojip.h	2002-07-25 02:01:24.000000000 -0700
+++ hpoj-0.91-davidm/include/hpojip.h	2004-11-11 21:19:58.775236374 -0800
@@ -131,12 +132,15 @@
 	float fl;
 } DWORD_OR_PVOID;
 
+#pragma pack ()
+
 #ifdef HPOJIP_INTERNAL
 #include "../lib/hpojip/xform.h"   // this file uses the above definitions
 #else
 typedef struct IP_XFORM_TBL_s FAR *LPIP_XFORM_TBL;
 #endif
 
+#pragma pack (1)
 
 /****************************************************************************\
  ****************************************************************************
@@ -587,8 +591,6 @@
 
 EXPORT(WORD) ipGetFuncPtrs (LPIP_JUMP_TBL lpJumpTbl);
 
-#pragma pack ()
-
 /****************************************************************************\
  ****************************************************************************
  *
