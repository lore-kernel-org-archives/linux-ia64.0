From: Russell King <rmk@arm.linux.org.uk>
Date: Sun, 02 May 2004 17:50:46 +0000
Subject: Re: [PATCH] 8250_hcdp needs irq sharing
Message-Id: <20040502185046.C17905@flint.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1082990579.15656.31.camel@localhost>
In-Reply-To: <1082990579.15656.31.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Apr 26, 2004 at 08:42:59AM -0600, Alex Williamson wrote:
>    Here's a trivial patch that makes 8250_hcdp setup the correct flags
> when IRQ sharing is enabled for serial ports.  Please apply.  Thanks,

If IRQ sharing is a property of 8250_hdcp-based ports, I'd rather
this was done unconditionally rather than being dependent on
CONFIG_SERIAL_8250_SHARE_IRQ.  8250_pci does it this way as well -
PCI inherently allows IRQs to be shared, so there's no reason to
make it depend on the configuration.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
