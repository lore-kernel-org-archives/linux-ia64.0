From: <peterc@gelato.unsw.edu.au>
Date: Fri, 14 Jun 2002 00:49:39 +0000
Subject: [Linux-ia64] Minor patch: remove warning in simserial.c
Message-Id: <marc-linux-ia64-105590701905675@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

simserial.c needs hw_irq.h to get the declaration for ia64_alloc_irq()


--- /tmp/geta9559	Fri Jun 14 10:45:35 2002
+++ linux-2.5.18-patched/arch/ia64/hp/sim/simserial.c	Fri Jun 14 10:42:40 2002
@@ -31,6 +31,7 @@
 #include <linux/serialP.h>
 
 #include <asm/irq.h>
+#include <asm/hw_irq.h>
 #include <asm/uaccess.h>
 
 #ifdef CONFIG_KDB

--
Peter C					    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.

