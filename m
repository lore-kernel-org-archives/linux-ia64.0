From: Russell King <rmk@arm.linux.org.uk>
Date: Sat, 21 Feb 2004 22:43:39 +0000
Subject: Re: [PATCH] Fix /proc serial info for MMIO ports
Message-Id: <20040221224339.B18248@flint.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402101628.31933.bjorn.helgaas@hp.com>
In-Reply-To: <200402101628.31933.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 10, 2004 at 04:28:31PM -0700, Bjorn Helgaas wrote:
> This patch against 2.6.2 fixes a minor issue with /proc/tty/drivers/serial,
> which currently doesn't show MMIO address information.  Current
> sample output:

Applied, thanks.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
