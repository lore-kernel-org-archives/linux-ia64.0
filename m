From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 30 Jun 2004 00:44:10 +0000
Subject: Re: bk pull on ia64 linux tree
Message-Id: <16610.3290.608017.47836@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

David> Hi Linus, please do a

David> 	bk pull http://lia64.bkbits.net/to-linus-2.5

David> This will update the files shown below.

David,
	even after doing this I see 
 CC      drivers/firmware/pcdp.o
/home/peterc/kernels/linux-2.6-preempt-davidm/drivers/firmware/pcdp.c:
In function `setup_serial_console':
/home/peterc/kernels/linux-2.6-preempt-davidm/drivers/firmware/pcdp.c:67:
warning: implicit declaration of function `ioremap'
/home/peterc/kernels/linux-2.6-preempt-davidm/drivers/firmware/pcdp.c:67:
warning: assignment makes pointer from integer without a cast

...

drivers/built-in.o(.init.text+0x11262): In function
`setup_serial_console': : undefined reference to `ioremap'

when building for ZX1.

I found I needed this patch:


Index: linux-2.6-preempt-davidm/drivers/firmware/pcdp.c
=================================--- linux-2.6-preempt-davidm.orig/drivers/firmware/pcdp.c
+++ linux-2.6-preempt-davidm/drivers/firmware/pcdp.c
@@ -14,6 +14,7 @@
 #include <linux/serial.h>
 #include <linux/serial_core.h>
 #include <asm/serial.h>
+#include <asm/io.h>
 #include "pcdp.h"
 
 static inline int
