From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 26 Oct 2004 07:48:56 +0000
Subject: Re: ia64 implementation of lib/iomap.c
Message-Id: <16766.360.725296.4208@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16759.51459.598187.91726@napali.hpl.hp.com>
In-Reply-To: <16759.51459.598187.91726@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 25 Oct 2004 10:48:48 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> On Thursday 21 October 2004 8:34 am, David Mosberger wrote:
  >> Is anybody already working on an ia64-version of lib/iomap.c?

  Bjorn> Here's a start (also attached, because of the kmail bug that
  Bjorn> corrupts whitespace).

Nice!

  Bjorn> The idea is that all MMIO iomem cookies are in region 6, so
  Bjorn> anything less than that must be a PIO cookie.  So we have:

  Bjorn> 0xCxxxxxxxxxxxxxxx MMIO cookie (return from ioremap)
  Bjorn> 0xRxxxxxxx1SPPPPPP PIO cookie (R=[0-9AB], S=space num, P..P=port)

In reality, `R' is always 0 though, right?  Would it be useful to add
the above two lines to asm-ia64/io.h?  I think they really help
understanding the code.  Perhaps it would also be useful to point out
that the "1" bit is there to catch old/buggy code which attempts to do
an I/O operation on a port without the prerequisite iomap()?

  Bjorn> I heard a rumor that ioreadX() on PIO cookies is supposed to
  Bjorn> have looser semantics than inX() on the port, so we might be
  Bjorn> able to get away without the memory fence in inb().  But I
  Bjorn> can't substantiate that, so this keeps the generic behavior
  Bjorn> of ioreadX() and inX() having identical semantics for PIO.

Can somebody confirm?  Dropping the mf.a from ioreadX() for I/O port
accesses would save lots of cycles.  Though I guess most
high-performance devices are smart enough to stay away from I/O port
space nowadays, so perhaps it doesn't matter in reality.

Thanks,

	--david
