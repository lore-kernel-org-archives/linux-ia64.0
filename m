From: Keith Rich <kxr@cthulhu.engr.sgi.com>
Date: Thu, 02 Aug 2007 17:38:51 +0000
Subject: Re: [RFC][PATCH 0/2] SN platform needs platform_irq_to_vector?
Message-Id: <46B216AB.mailxFYV110PTO@cthulhu.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186028871.3875.12.camel@kane-linux>
In-Reply-To: <1186028871.3875.12.camel@kane-linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-----------------------------------------------------------------
irq 30, desc: a000000100c37000, depth: 1, count: 0, unhandled: 0
->handle_irq():  a0000001009a6a50, __end_rodata+0x5010/0x225c0
->chip(): a000000100dfee80, irq_type_sn+0x0/0x80
->action(): 0000000000000000
  IRQ_DISABLED set
Unexpected irq vector 0x1e on CPU 0!
-----------------------------------------------------------------

Russ,  I see this on dorado, but not on A4700.
I don't understand why there's a difference.

Keith
