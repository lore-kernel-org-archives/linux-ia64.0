From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 27 May 2003 04:08:29 +0000
Subject: [Linux-ia64] Fix ps/2 mouse and keyboard on I2000, 2.5.69-bk
MIME-Version: 1
Content-Type: multipart/mixed; boundary="kHwtAPD/q8"
Message-Id: <marc-linux-ia64-105590723706042@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--kHwtAPD/q8
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit


I finally got sufficiently fed up to fix the PS/2 keyboard.  The
problem is that the generic code requests an ISA interrupt directly,
instead of via isa_irq_to_vector().


--kHwtAPD/q8
Content-Type: text/plain
Content-Disposition: inline;
	filename="p1"
Content-Transfer-Encoding: 7bit

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1101  -> 1.1102 
#	drivers/input/serio/i8042-io.h	1.4     -> 1.5    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/27	peterc@wombat.disy.cse.unsw.edu.au	1.1102
# IA64: Fix  I2000 no keyboard interrupt problem.
# --------------------------------------------
#
diff -Nru a/drivers/input/serio/i8042-io.h b/drivers/input/serio/i8042-io.h
--- a/drivers/input/serio/i8042-io.h	Tue May 27 14:07:29 2003
+++ b/drivers/input/serio/i8042-io.h	Tue May 27 14:07:29 2003
@@ -20,11 +20,14 @@
  */
 
 #ifdef __alpha__
-#define I8042_KBD_IRQ	1
-#define I8042_AUX_IRQ	(RTC_PORT(0) == 0x170 ? 9 : 12)	/* Jensen is special */
+# define I8042_KBD_IRQ	1
+# define I8042_AUX_IRQ	(RTC_PORT(0) == 0x170 ? 9 : 12)	/* Jensen is special */
+#elif defined(__ia64__)
+# define I8042_KBD_IRQ isa_irq_to_vector(1)
+# define I8042_AUX_IRQ isa_irq_to_vector(12)
 #else
-#define I8042_KBD_IRQ	1
-#define I8042_AUX_IRQ	12
+# define I8042_KBD_IRQ	1
+# define I8042_AUX_IRQ	12
 #endif
 
 /*

--kHwtAPD/q8--

