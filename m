From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 01 Oct 2002 04:26:25 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.39)
Message-Id: <marc-linux-ia64-105590701906077@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

To get  the new patched version to compile without a VGA card, (using
serial console) I needed this patch:

--- /tmp/geta5135 2002-10-01 14:02:36.000000000 +1000
+++ linux-2.5-ia64-merge/kernel/printk.c	  2002-10-01 14:01:47.000000000 +1000
@@ -718,9 +718,10 @@
 
 #ifdef CONFIG_IA64_EARLY_PRINTK
 
+#include <asm/io.h>
+
 # ifdef CONFIG_IA64_EARLY_PRINTK_VGA
 
-#include <asm/io.h>
 
 #define VGABASE		((char *)0xc0000000000b8000)
 #define VGALINES		24

