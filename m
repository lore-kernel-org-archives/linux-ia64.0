From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 29 Mar 2004 18:58:47 +0000
Subject: [PATCH] fix sn_serial warning
Message-Id: <200403291058.47096.jbarnes@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_nHHaArtF/eaC3/S"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_nHHaArtF/eaC3/S
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

In my fixes to quiet the sn_serial driver, I made sn_debug_printf only get 
used when the DEBUG define was turned on in the driver but forgot to #ifdef 
out the function definition, causing an 'defined but not used' warning.  This 
patch fixes that.

Jesse

--Boundary-00=_nHHaArtF/eaC3/S
Content-Type: text/plain;
  charset="us-ascii";
  name="sn-serial-warning-fixes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn-serial-warning-fixes.patch"

===== drivers/char/sn_serial.c 1.10 vs edited =====
--- 1.10/drivers/char/sn_serial.c	Mon Mar 22 02:29:18 2004
+++ edited/drivers/char/sn_serial.c	Mon Mar 29 10:48:14 2004
@@ -82,10 +82,10 @@
 static unsigned long sn_interrupt_timeout;
 
 extern u64 master_node_bedrock_address;
-static int sn_debug_printf(const char *fmt, ...);
 
 #undef DEBUG
 #ifdef DEBUG
+static int sn_debug_printf(const char *fmt, ...);
 #define DPRINTF(x...) sn_debug_printf(x)
 #else
 #define DPRINTF(x...) do { } while (0)
@@ -247,6 +247,7 @@
 	sn_func->sal_puts(s, count);
 }
 
+#ifdef DEBUG
 /* this is as "close to the metal" as we can get, used when the driver
  * itself may be broken */
 static int
@@ -262,6 +263,7 @@
 	va_end(args);
 	return printed_len;
 }
+#endif /* DEBUG */
 
 /*
  * Interrupt handling routines.

--Boundary-00=_nHHaArtF/eaC3/S--
