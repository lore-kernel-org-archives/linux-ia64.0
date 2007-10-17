From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 17 Oct 2007 04:40:03 +0000
Subject: Re: [RFC patch] fallback to "no irq" hack for case of no pnp_irq allocated for 8250_pnp
Message-Id: <20071017044003.GC16728@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0710161950n3d255330lf55e190dde628277@mail.gmail.com>
In-Reply-To: <3877989d0710161950n3d255330lf55e190dde628277@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luming Yu <luming.yu@gmail.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 17, 2007 at 10:50:53AM +0800, Luming Yu wrote:
> There is a "ttyS1 irq is -1" problem observed on tiger4 which cause
> the serial port broken.
> It is because that there is __no__ ACPI IRQ resource assigned for the
> serial port. So the value of the IRQ for the port is never changed
> since it got initialized to -1. The attached patch falls back to the
> "no irq" hack for this case. It works for me. Please review and test.

Seems reasonable to me.  Although arguably pnp_irq is broken, since
Linus has decreed that 0 means no irq on Linux.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
