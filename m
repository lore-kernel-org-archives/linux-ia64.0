From: Peter Korsgaard <peter@korsgaard.com>
Date: Mon, 29 Apr 2019 15:24:53 +0000
Subject: Re: [PATCH 16/41] drivers: tty: serial: uartlite: fix overlong lines
Message-Id: <87a7g8rfzu.fsf@dell.be.48ers.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
        <1556369542-13247-17-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-17-git-send-email-info@metux.net> (Enrico
        Weigelt's message of "Sat, 27 Apr 2019 14:51:57 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, lorenzo.pieralisi@arm.com, linux-ia64@vger.kernel.org, linux-serial@vger.kernel.org, andrew@aj.id.au, gregkh@linuxfoundation.org, sudeep.holla@arm.com, liviu.dudau@arm.com, linux-mips@vger.kernel.org, vz@mleia.com, linux@prisktech.co.nz, sparclinux@vger.kernel.org, khilman@baylibre.com, macro@linux-mips.org, slemieux.tyco@gmail.com, matthias.bgg@gmail.com, jacmet@sunsite.dk, linux-amlogic@lists.infradead.org, andriy.shevchenko@linux.intel.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net

>>>>> "Enrico" = Enrico Weigelt, metux IT consult <info@metux.net> writes:

 > Fix checkpatch warnings:
 >     WARNING: line over 80 characters
 >     #283: FILE: drivers/tty/serial/uartlite.c:283:
 >     +	ret = request_irq(port->irq, ulite_isr, IRQF_SHARED | IRQF_TRIGGER_RISING,

 >     WARNING: Missing a blank line after declarations
 >     #577: FILE: drivers/tty/serial/uartlite.c:577:
 >     +	struct earlycon_device *device = console->data;
 >     +	uart_console_write(&device->port, s, n, early_uartlite_putc);

 >     WARNING: line over 80 characters
 >     #590: FILE: drivers/tty/serial/uartlite.c:590:
 >     +OF_EARLYCON_DECLARE(uartlite_b, "xlnx,opb-uartlite-1.00.b", early_uartlite_setup);

 >     WARNING: line over 80 characters
 >     #591: FILE: drivers/tty/serial/uartlite.c:591:
 >     +OF_EARLYCON_DECLARE(uartlite_a, "xlnx,xps-uartlite-1.00.a", early_uartlite_setup);

Given that these are just a few characters more than 80 I don't really
think these changes improve readability.


 > Signed-off-by: Enrico Weigelt <info@metux.net>
 > ---
 >  drivers/tty/serial/uartlite.c | 10 +++++++---
 >  1 file changed, 7 insertions(+), 3 deletions(-)

 > diff --git a/drivers/tty/serial/uartlite.c b/drivers/tty/serial/uartlite.c
 > index 6f79353..0140cec 100644
 > --- a/drivers/tty/serial/uartlite.c
 > +++ b/drivers/tty/serial/uartlite.c
 > @@ -280,7 +280,8 @@ static int ulite_startup(struct uart_port *port)
 >  		return ret;
 >  	}
 
 > -	ret = request_irq(port->irq, ulite_isr, IRQF_SHARED | IRQF_TRIGGER_RISING,
 > +	ret = request_irq(port->irq, ulite_isr,
 > +			  IRQF_SHARED | IRQF_TRIGGER_RISING,
 >  			  "uartlite", port);
 >  	if (ret)
 >  		return ret;
 > @@ -574,6 +575,7 @@ static void early_uartlite_write(struct console *console,
 >  				 const char *s, unsigned int n)
 >  {
 >  	struct earlycon_device *device = console->data;
 > +
 >  	uart_console_write(&device->port, s, n, early_uartlite_putc);

Unrelated change?

-- 
Bye, Peter Korsgaard
