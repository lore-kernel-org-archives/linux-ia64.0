From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 08 Mar 2004 22:05:21 +0000
Subject: Re: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <200403081505.21644.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F8401B1A017@PDSMSX403.ccr.corp.intel.com> <16460.59685.452893.22564@napali.hpl.hp.com> <20040308215448.I21938@flint.arm.linux.org.uk>
In-Reply-To: <20040308215448.I21938@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+lkml@arm.linux.org.uk>, davidm@hpl.hp.com
Cc: Takayoshi Kochi <t-kochi@bq.jp.nec.com>, benjamin.liu@intel.com, iod00d@hp.com, kaneshige.kenji@jp.fujitsu.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Monday 08 March 2004 2:54 pm, Russell King wrote:
> OTOH, if you know "this port is absolutely definitely using this IRQ"
> then you don't want to use IRQ probing.
> 
> As long as ACPI positively knows the correct IRQ, so we really shouldn't
> be using IRQ probing here.  The only thing which causes me concern is...
> what about ACPI table/BIOS bugs?

I suspect (not being expert in the serial innards) that with the old
code things would "just work", and the ACPI table bug would never
be noticed.

With the new code, my guess is that the device just wouldn't work
(we think it has an interrupt, but it's not hooked up correctly).

My inclination is that it's better to help find ACPI bugs, and
if broken tables turn out to be a problem, we can add some kind
of command-line switch or blacklist to deal with it.  But I
guess we should really get David's opinion, since this is a
potential issue for 2.6 distributions.

Bjorn

