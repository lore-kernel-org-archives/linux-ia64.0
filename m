From: Pat Gefre <pfg@sgi.com>
Date: Wed, 28 Jul 2004 18:10:19 +0000
Subject: Re: [PATCH] Altix console mod
Message-Id: <Pine.SGI.3.96.1040728130932.120480A-100000@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407271953.i6RJrAma119179@fsgi900.americas.sgi.com>
In-Reply-To: <200407271953.i6RJrAma119179@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 27 Jul 2004, Andreas Schwab wrote:

+ Patrick Gefre <pfg@sgi.com> writes:
+ 
+ > You're right, I forgot the else on the if (to write out the lf) ....
+ > So send the cr even if one is already there - guess it doesn't hurt ?
+ 
+ The kernel normally does not output CRs anyway, since it's just using \n
+ for EOL.
+ 
+ Andreas.
+ 



Here's a better version:


# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/07/28 10:51:32-05:00 pfg@sgi.com 
#   drivers/serial/sn_console.c
#       move sn_debug_printf to only compile for DEBUG
#       early printk needs to handle missing carriage returns
# 
# drivers/serial/sn_console.c
#   2004/07/28 10:51:13-05:00 pfg@sgi.com +15 -12
#   move sn_debug_printf to only compile for DEBUG
#   early printk needs to handle missing carriage returns
# 
diff -Nru a/drivers/serial/sn_console.c b/drivers/serial/sn_console.c
--- a/drivers/serial/sn_console.c	2004-07-28 11:41:46 -05:00
+++ b/drivers/serial/sn_console.c	2004-07-28 11:41:46 -05:00
@@ -105,10 +105,9 @@
 extern u64 master_node_bedrock_address;
 extern void early_sn_setup(void);
 
-static int sn_debug_printf(const char *fmt, ...);
-
 #undef DEBUG
 #ifdef DEBUG
+static int sn_debug_printf(const char *fmt, ...);
 #define DPRINTF(x...) sn_debug_printf(x)
 #else
 #define DPRINTF(x...) do { } while (0)
@@ -489,6 +488,8 @@
 
 /* End of uart struct functions and defines */
 
+#ifdef DEBUG
+
 /**
  * sn_debug_printf - close to hardware debugging printf
  * @fmt: printf format
@@ -520,6 +521,7 @@
 	va_end(args);
 	return printed_len;
 }
+#endif	/* DEBUG */
 
 /*
  * Interrupt handling routines.
@@ -654,7 +656,7 @@
 				    port->sc_ops->sal_puts(start, xmit_count);
 #ifdef DEBUG
 			if (!result)
-				sn_debug_printf("`");
+				DPRINTF("`");
 #endif
 			if (result > 0) {
 				xmit_count -= result;
@@ -971,6 +973,7 @@
 
 /**
  * puts_raw_fixed - sn_sal_console_write helper for adding \r's as required
+ * @puts_raw : puts function to do the writing
  * @s: input string
  * @count: length
  *
@@ -978,19 +981,19 @@
  * ia64_sn_console_putb (what sal_puts_raw below actually does).
  *
  */
-static void puts_raw_fixed(const char *s, int count)
+
+static void puts_raw_fixed(int (*puts_raw) (const char *s, int len), const char *s, int count)
 {
 	const char *s1;
-	struct sn_cons_port *port = &sal_console_port;
 
 	/* Output '\r' before each '\n' */
 	while ((s1 = memchr(s, '\n', count)) != NULL) {
-		port->sc_ops->sal_puts_raw(s, s1 - s);
-		port->sc_ops->sal_puts_raw("\r\n", 2);
+		puts_raw(s, s1 - s);
+		puts_raw("\r\n", 2);
 		count -= s1 + 1 - s;
 		s = s1 + 1;
 	}
-	port->sc_ops->sal_puts_raw(s, count);
+	puts_raw(s, count);
 }
 
 /**
@@ -1072,7 +1075,7 @@
 				/* fell thru */
 				stole_lock = 1;
 			}
-			puts_raw_fixed(s, count);
+			puts_raw_fixed(port->sc_ops->sal_puts_raw, s, count);
 		}
 		else {
 			stole_lock = 0;
@@ -1081,12 +1084,12 @@
 			sn_transmit_chars(port, 1);
 			spin_unlock_irqrestore(&port->sc_port.lock, flags);
 
-			puts_raw_fixed(s, count);
+			puts_raw_fixed(port->sc_ops->sal_puts_raw, s, count);
 		}
 	}
 	else {
 		/* Not yet registered with serial core - simple case */
-		puts_raw_fixed(s, count);
+		puts_raw_fixed(port->sc_ops->sal_puts_raw, s, count);
 	}
 }
 
@@ -1123,7 +1126,7 @@
 static void __init
 sn_sal_console_write_early(struct console *co, const char *s, unsigned count)
 {
-	sal_console_port.sc_ops->sal_puts(s, count);
+	puts_raw_fixed(sal_console_port.sc_ops->sal_puts_raw, s, count);
 }
 
 /* Used for very early console printing - again, before

