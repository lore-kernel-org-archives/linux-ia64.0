From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 31 May 2003 00:40:05 +0000
Subject: [Linux-ia64] Re: Fix ps/2 mouse and keyboard on I2000, 2.5.69-bk
Message-Id: <marc-linux-ia64-105590723706096@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 27 May 2003 14:08:29 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> I finally got sufficiently fed up to fix the PS/2 keyboard.
  Peter> The problem is that the generic code requests an ISA
  Peter> interrupt directly, instead of via isa_irq_to_vector().

Thanks for tracking this down.  I applied it to my tree, but would you
mind shepherding it into the official 2.5 tree?  It looks like an
obvious bug fix, so I don't think there will be any problem in getting
it accepted.

Thanks,

	--david

