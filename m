From: Pat Gefre <pfg@sgi.com>
Date: Wed, 11 Aug 2004 23:31:54 +0000
Subject: Re: Altix I/O code reorganization - 11 of 21
Message-Id: <200408112331.i7BNVsWk140739@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hch@infradead.org


# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/11 16:26:33-05:00 pfg@sgi.com 
#   New klconfig Makefile
# 
# arch/ia64/sn/ioif/klconfig/Makefile
#   2004/08/11 16:24:39-05:00 pfg@sgi.com +10 -0
# 
# arch/ia64/sn/ioif/klconfig/Makefile
#   2004/08/11 16:24:39-05:00 pfg@sgi.com +0 -0
#   BitKeeper file /work.attica2/pfg/Linux/2.5-BK/to-base-2.6/arch/ia64/sn/ioif/klconfig/Makefile
# 
diff -Nru a/arch/ia64/sn/ioif/klconfig/Makefile b/arch/ia64/sn/ioif/klconfig/Makefile
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/arch/ia64/sn/ioif/klconfig/Makefile	2004-08-11 16:27:03 -05:00
@@ -0,0 +1,10 @@
+#
+# This file is subject to the terms and conditions of the GNU General Public
+# License.  See the file "COPYING" in the main directory of this archive
+# for more details.
+#
+# Copyright (C) 2002-2003 Silicon Graphics, Inc.  All Rights Reserved.
+#
+# Makefile for the sn2 io routines.
+
+obj-y				:=  klconflib.o
