From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 16 Oct 2003 16:58:56 +0000
Subject: [PATCH] serial console registration bugfix (2.6)
Message-Id: <marc-linux-ia64-106632357111519@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

uart_set_options() can dereference a null pointer.  This happens
if you specify a console that hasn't previously been setup by
early_serial_setup().

For example, on ia64, the HCDP typically tells us about line 0,
so we calls early_serial_setup() for it.  If the user specifies
"console=ttyS3", we machine-check when trying to follow the
uninitialized port->ops pointer.

It's not entirely clear to me whether we should return 0 or -ENODEV
or something.  The advantage of returning zero is that if the user
specifies "console=ttyS0" and we just lack the HCDP, the console
doesn't work as early as usual, but it does start working after the
serial driver detects the port (though the baud/parity/etc from the
command line are lost).  Returning -ENODEV seems to prevent it from
ever working.

Bjorn

=== drivers/serial/serial_core.c 1.72 vs edited ==--- 1.72/drivers/serial/serial_core.c	Mon Sep 29 18:35:33 2003
+++ edited/drivers/serial/serial_core.c	Thu Oct 16 09:56:55 2003
@@ -1859,6 +1859,9 @@
 	if (flow = 'r')
 		termios.c_cflag |= CRTSCTS;
 
+	if (!port->ops)
+		return 0;
+
 	port->ops->set_termios(port, &termios, NULL);
 	co->cflag = termios.c_cflag;
 

