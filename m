From: Russell King <rmk@arm.linux.org.uk>
Date: Fri, 16 Jan 2004 22:02:16 +0000
Subject: Re: [PATCH] make HCDP dependent on serial console
Message-Id: <20040116220216.A5904@flint.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401131706.56756.bjorn.helgaas@hp.com>
In-Reply-To: <200401131706.56756.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 13, 2004 at 05:06:56PM -0700, Bjorn Helgaas wrote:
> I propose the following HCDP Kconfig patch.  It makes HCDP
> selectable only when serial console has been selected.  One
> desirable side effect is that both are then available only
> when statically compiled in (i.e., not built as a module).

Applied.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
