From: MUNEDA Takahiro <muneda.takahiro@jp.fujitsu.com>
Date: Wed, 20 Jun 2007 04:00:00 +0000
Subject: [PATCH 2.6.22-rc5] remove duplicate header include line
Message-Id: <200706201300.01923.muneda.takahiro@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

<linux/profile.h> is included twice. This patch removes the duplication.
I've confirmed the binary file with/without patch is completely same.

Thanks,
MUNE

Remove duplicate header include line from arch/ia64/kernel/time.c.

Signed-off-by: MUNEDA Takahiro <muneda.takahiro@jp.fujitsu.com>

---
 arch/ia64/kernel/time.c |    1 -
 1 files changed, 1 deletion(-)

Index: linux-2.6.22-rc5/arch/ia64/kernel/time.c
=================================--- linux-2.6.22-rc5.orig/arch/ia64/kernel/time.c	2007-06-17 11:09:12.000000000 +0900
+++ linux-2.6.22-rc5/arch/ia64/kernel/time.c	2007-06-20 12:28:04.000000000 +0900
@@ -18,7 +18,6 @@
 #include <linux/time.h>
 #include <linux/interrupt.h>
 #include <linux/efi.h>
-#include <linux/profile.h>
 #include <linux/timex.h>
 
 #include <asm/machvec.h>




