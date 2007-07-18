From: "Robert P. J. Day" <rpjday@mindspring.com>
Date: Wed, 18 Jul 2007 11:33:08 +0000
Subject: [PATCH] IA64:  Prevent people from directly including <asm/rwsem.h>.
Message-Id: <Pine.LNX.4.64.0707180730190.14901@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>

---

diff --git a/include/asm-ia64/rwsem.h b/include/asm-ia64/rwsem.h
index 2d1640c..99651d7 100644
--- a/include/asm-ia64/rwsem.h
+++ b/include/asm-ia64/rwsem.h
@@ -21,6 +21,10 @@
 #ifndef _ASM_IA64_RWSEM_H
 #define _ASM_IA64_RWSEM_H

+#ifndef _LINUX_RWSEM_H
+#error "Please don't include <asm/rwsem.h> directly, use <linux/rwsem.h> instead."
+#endif
+
 #include <linux/list.h>
 #include <linux/spinlock.h>


-- 
====================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
====================================
