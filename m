From: Russell King <rmk@arm.linux.org.uk>
Date: Sat, 25 Mar 2006 17:47:21 +0000
Subject: Re: [PATCH] serial: remove 8250_acpi (replaced by 8250_pnp and PNPACPI)
Message-Id: <20060325174721.GG6100@flint.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603011700.27683.bjorn.helgaas@hp.com>
In-Reply-To: <200603011700.27683.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-serial@vger.kernel.org, len.brown@intel.com, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>

On Wed, Mar 01, 2006 at 05:00:27PM -0700, Bjorn Helgaas wrote:
> [This is post-2.6.16 material]
> 
> With the combination of PNPACPI and 8250_pnp, we no longer need 8250_acpi.

Applied, thanks.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 Serial core
