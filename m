From: Russell King <rmk@arm.linux.org.uk>
Date: Sat, 21 Feb 2004 22:43:27 +0000
Subject: Re: [PATCH] Discover ACPI serial ports before plug-in ports
Message-Id: <20040221224327.A18248@flint.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402101611.22768.bjorn.helgaas@hp.com>
In-Reply-To: <200402101611.22768.bjorn.helgaas@hp.com>; from bjorn.helgaas@hp.com on Tue, Feb 10, 2004 at 04:11:22PM -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-ia64@vger.kernel.org, acpi-devel@lists.sourceforge.net

On Tue, Feb 10, 2004 at 04:11:22PM -0700, Bjorn Helgaas wrote:
> I propose the following patch (against 2.6.2).  This makes us
> discover ACPI serial ports before PCI ones.  The ACPI ports
> tend to be built-in, and discovering them late means their ttyS
> names move around if PCI serial ports are added or removed.  I
> think it makes more sense to have relatively predictable and
> consistent names for the built-in hardware.

Applied, thanks.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
