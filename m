From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 26 Aug 2003 16:24:43 +0000
Subject: Re: serial legacy ports and ACPI
Message-Id: <marc-linux-ia64-106191580620525@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105761215001812@msgid-missing>
In-Reply-To: <marc-linux-ia64-105761215001812@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen wrote:
> 
> I had a chat with Grant and Matthew about is a little while ago (and
> possibly a few other people whom I can't remember right now) and we
> basically came to a similar conclusion. Once I find a bit more time,
> I'd like to introduce an interface along the lines of
> 
>         legacy_device_present(LEGACY_{IDE,SERIAL,PARALLEL})
> 
> This could be quite useful for other architectures as well I believe.

Jes,

   Digging up an old topic.  I started looking at this from a serial
port numbering perspective and came up with a fairly simple way for
the architecure code to handle it on it's own.  Here's my idea vs
2.6:

--- linux/arch/ia64/kernel/acpi.c
+++ linux/arch/ia64/kernel/acpi.c
@@ -41,6 +41,9 @@
 #include <linux/irq.h>
 #include <linux/acpi.h>
 #include <linux/efi.h>
+#include <linux/tty.h>
+#include <linux/serial.h>
+#include <linux/serial_core.h>
 #include <asm/io.h>
 #include <asm/iosapic.h>
 #include <asm/machvec.h>
@@ -530,6 +533,20 @@
        if (!(fadt->iapc_boot_arch & BAF_8042_KEYBOARD_CONTROLLER))
                acpi_kbd_controller_present = 0;
 
+#ifdef CONFIG_SERIAL_8250
+       if (!(fadt->iapc_boot_arch & BAF_LEGACY_DEVICES)) {
+               int i;
+               struct uart_port port;
+
+               memset(&port, 0, sizeof(port));
+
+               for (i = 0 ; i < 4 ; i++) {
+                       port.line = i;
+                       early_serial_setup(&port);
+               }
+       }
+#endif
+
        acpi_register_irq(fadt->sci_int, ACPI_ACTIVE_LOW, ACPI_LEVEL_SENSITIVE);
        return 0;
 }

   This example only hits the first 4 ports, but we could clear the whole
table if we decide that's the right thing to do.  Does anybody really
use EXTRA_SERIAL_PORT_DEFNS and HUB6_SERIAL_PORT_DFNS or should those
be considered "legacy" as well?  The serial port part of this problem
kind of feels like an architecture problem since we start out passing
in a table of serial ports to probe.  Thoughts?

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab
