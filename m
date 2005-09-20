From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 20 Sep 2005 16:04:31 +0000
Subject: Re: [PATCH] serial: remove 8250_acpi (subsumed by 8250_pnp and PNPACPI)
Message-Id: <200509201004.31224.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509161142.33723.bjorn.helgaas@hp.com>
In-Reply-To: <200509161142.33723.bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+serial-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Cc: linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mattieu Castet <castet.matthieu-GANU6spQydw@public.gmane.org>, Li Shaohua <shaohua.li-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

On Friday 16 September 2005 11:42 am, Bjorn Helgaas wrote:
> With the combination of PNPACPI and 8250_pnp, we no longer need
> 8250_acpi.
> 
> The only in-tree configs that contain CONFIG_SERIAL_8250_ACPI are ia64.
> ia64 users should make sure CONFIG_PNP and CONFIG_PNPACPI are set so
> 8250_pnp.c can discover built-in serial ports.  Tony has already
> accepted a patch to turn them on in the default configs.

Please don't apply this just yet.  Tony Luck tried it and tripped
over a deficiency in PNPACPI that I'll have to fix first.

(HP rx1620 has an ACPI_RSTYPE_ADDRESS32 item in its _PRS, and
PNPACPI doesn't know what to do with it.)
