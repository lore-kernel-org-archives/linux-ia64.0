From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 27 Sep 2010 19:54:06 +0000
Subject: Re: [RFC trollpatch 1/1] genirq: Remove the fits all and nothing
Message-Id: <alpine.LFD.2.00.1009272152360.2416@localhost6.localdomain6>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="-1463795968-1112802732-1285617250=:2416"
List-Id: <linux-ia64.vger.kernel.org>
References: <20100908152036.643594727@linutronix.de> <AANLkTin23sJT+OqjDqjyk-Gr5r-GfJ_03Q1WUqNLCzgH@mail.gmail.com>
In-Reply-To: <AANLkTin23sJT+OqjDqjyk-Gr5r-GfJ_03Q1WUqNLCzgH@mail.gmail.com>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-alpha@vger.kernel.org, linux-cris-kernel@axis.com, Haavard Skinnemoen <hskinnemoen@atmel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, Jeff Dike <jdike@addtoit.com>, linux-parisc@vger.kernel.org, Chris Zankel <chris@zankel.net>, linux-arch@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463795968-1112802732-1285617250=:2416
Content-Type: TEXT/PLAIN; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Mon, 27 Sep 2010, richard -rw- weinberger wrote:

> On Wed, Sep 8, 2010 at 8:14 PM, Thomas Gleixner <tglx@linutronix.de> wrot=
e:
> > __do_IRQ() has been deprecated after a two years migration phase in
> > =A0The following architectures are still using __do_IRQ():
> >
> > =A0alpha, cris, ia64, h8300, m32r, m68knommu, parisc, um
> >
>=20
> Maybe I'm naive but shouldn't this path work?
> Does um need some extra work?

Yes. It needs to set the proper flow handlers. Look for set_irq_chip*
functions and how they are used in other archs.

Thanks,

	tglx

=20
---1463795968-1112802732-1285617250=:2416--
