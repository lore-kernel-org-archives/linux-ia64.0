From: Pat Gefre <pfg@sgi.com>
Date: Mon, 15 Mar 2004 21:19:31 +0000
Subject: [PATCH] 2.6 ia64 - Altix console code missing brace
Message-Id: <200403152119.i2FLJWl3101955@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The last mod to fix the staircase printing - missed some bracing....


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1695  -> 1.1696 
#	drivers/char/sn_serial.c	1.7     -> 1.8    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/03/15	pfg@sgi.com	1.1696
# drivers/char/sn_serial.c
#     Last mod left out the braces ....
# --------------------------------------------
#
diff -Nru a/drivers/char/sn_serial.c b/drivers/char/sn_serial.c
--- a/drivers/char/sn_serial.c	Mon Mar 15 14:28:24 2004
+++ b/drivers/char/sn_serial.c	Mon Mar 15 14:28:24 2004
@@ -978,7 +978,7 @@
 		}
 		sn_func->sal_puts(s, count);
 	}
-	else
+	else {
 		/* Output '\r' before each '\n' */
 		while ((s1 = memchr(s, '\n', count)) != NULL) {
 			sn_sal_write(NULL, 0, s, s1 - s);
@@ -987,6 +987,7 @@
 			s = s1 + 1;
 		}
 		sn_sal_write(NULL, 0, s, count);
+	}
 }
 
 static struct tty_driver *
