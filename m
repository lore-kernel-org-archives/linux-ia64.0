From: Jes Sorensen <jes@sgi.com>
Date: Mon, 13 Feb 2006 10:32:09 +0000
Subject: [patch] remote obsolete corporate address
Message-Id: <yq0slqny2fq.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This one removes a now obsolete SGI corporate address from a few
files.

Cheers,
Jes


Remove obsolete SGI address

Signed-off-by: Jes Sorensen <jes@sgi.com>

----

 arch/ia64/sn/kernel/sn2/timer_interrupt.c |    7 +------
 drivers/ide/pci/sgiioc4.c                 |    5 -----
 include/asm-ia64/machvec_sn2.h            |    7 +------
 3 files changed, 2 insertions(+), 17 deletions(-)

Index: linux-2.6/arch/ia64/sn/kernel/sn2/timer_interrupt.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/sn2/timer_interrupt.c
+++ linux-2.6/arch/ia64/sn/kernel/sn2/timer_interrupt.c
@@ -1,7 +1,7 @@
 /*
  *
  *
- * Copyright (c) 2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2005, 2006 Silicon Graphics, Inc.  All Rights Reserved.
  * 
  * This program is free software; you can redistribute it and/or modify it 
  * under the terms of version 2 of the GNU General Public License 
@@ -22,11 +22,6 @@
  * License along with this program; if not, write the Free Software 
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
  * 
- * Contact information:  Silicon Graphics, Inc., 1600 Amphitheatre Pkwy, 
- * Mountain View, CA  94043, or:
- * 
- * http://www.sgi.com 
- * 
  * For further information regarding this notice, see: 
  * 
  * http://oss.sgi.com/projects/GenInfo/NoticeExplan
Index: linux-2.6/drivers/ide/pci/sgiioc4.c
=================================--- linux-2.6.orig/drivers/ide/pci/sgiioc4.c
+++ linux-2.6/drivers/ide/pci/sgiioc4.c
@@ -13,11 +13,6 @@
  * License along with this program; if not, write the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
  *
- * Contact information:  Silicon Graphics, Inc., 1600 Amphitheatre Pkwy,
- * Mountain View, CA  94043, or:
- *
- * http://www.sgi.com
- *
  * For further information regarding this notice, see:
  *
  * http://oss.sgi.com/projects/GenInfo/NoticeExplan
Index: linux-2.6/include/asm-ia64/machvec_sn2.h
=================================--- linux-2.6.orig/include/asm-ia64/machvec_sn2.h
+++ linux-2.6/include/asm-ia64/machvec_sn2.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2002-2003 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2002-2003, 2006 Silicon Graphics, Inc.  All Rights Reserved.
  * 
  * This program is free software; you can redistribute it and/or modify it 
  * under the terms of version 2 of the GNU General Public License 
@@ -20,11 +20,6 @@
  * License along with this program; if not, write the Free Software 
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
  * 
- * Contact information:  Silicon Graphics, Inc., 1600 Amphitheatre Pkwy, 
- * Mountain View, CA  94043, or:
- * 
- * http://www.sgi.com 
- * 
  * For further information regarding this notice, see: 
  * 
  * http://oss.sgi.com/projects/GenInfo/NoticeExplan
