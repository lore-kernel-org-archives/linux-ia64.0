From: Russell King <rmk@arm.linux.org.uk>
Date: Tue, 04 May 2004 16:57:58 +0000
Subject: Re: [PATCH] default to serial console when possible
Message-Id: <20040504175758.D22911@flint.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405041017.13247.bjorn.helgaas@hp.com>
In-Reply-To: <200405041017.13247.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 04, 2004 at 10:17:13AM -0600, Bjorn Helgaas wrote:
> This adds efi_uart_console_only() so we can default to using a serial
> console if the EFI console path only contains UARTs.

Applied, thanks.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
