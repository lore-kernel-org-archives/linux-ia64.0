From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Thu, 05 Feb 2004 06:11:36 +0000
Subject: [patch] 2.6.2-rc2 Remove compile warnings from timer.o
Message-Id: <20040205061136.GD25002@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This ia a relatively simple patch to remove compile warnings:

kernel/timer.c: In function `second_overflow':
kernel/timer.c:589: warning: right shift count is negative
kernel/timer.c:592: warning: right shift count is negative

when CONFIG_IA64_HP_SIM=y. 

Tested with SIM boots and compile.

--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------

--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="param.h.patch"

--- ../tmp/linux-2.6.2-rc2/include/asm-ia64/param.h	2004-02-05 14:09:33.000000000 +1100
+++ linux-2.6.2-rc2/include/asm-ia64/param.h	2004-02-05 13:23:21.000000000 +1100
@@ -27,7 +27,7 @@
    * Yeah, simulating stuff is slow, so let us catch some breath between
    * timer interrupts...
    */
-#  define HZ	  32
+#  define HZ	  96
 # else
 #  define HZ	1024
 # endif

--VS++wcV0S1rZb1Fb--
