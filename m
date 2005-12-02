From: Keith Owens <kaos@sgi.com>
Date: Fri, 02 Dec 2005 02:40:15 +0000
Subject: [patch 2.6.15-rc4] Allow salinfo_decode to detect signals on read
Message-Id: <4727.1133491215@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Return -EINTR instead of -ERESTARTSYS when signals are delivered during
a blocked read of /proc/sal/*/event.  This allows salinfo_decode to
detect signals when it is blocked on a read of those files.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/kernel/salinfo.c
=================================--- linux.orig/arch/ia64/kernel/salinfo.c	2005-12-02 13:34:44.753350991 +1100
+++ linux/arch/ia64/kernel/salinfo.c	2005-12-02 13:35:12.055229613 +1100
@@ -293,7 +293,7 @@ retry:
 		if (file->f_flags & O_NONBLOCK)
 			return -EAGAIN;
 		if (down_interruptible(&data->sem))
-			return -ERESTARTSYS;
+			return -EINTR;
 	}
 
 	n = data->cpu_check;

