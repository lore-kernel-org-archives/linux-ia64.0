From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 27 Sep 2010 18:01:26 +0000
Subject: Re: [RFC trollpatch 1/1] genirq: Remove the fits all and nothing
Message-Id: <alpine.LFD.2.00.1009271953390.2416@localhost6.localdomain6>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="-1463795968-1703548383-1285610489=:2416"
List-Id: <linux-ia64.vger.kernel.org>
References: <20100908152036.643594727@linutronix.de> <AANLkTikVHO9DmyTX==CwViDK1rP0masBwjMakHZ0U=kZ@mail.gmail.com>
In-Reply-To: <AANLkTikVHO9DmyTX==CwViDK1rP0masBwjMakHZ0U=kZ@mail.gmail.com>
To: Tony Luck <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-alpha@vger.kernel.org, linux-cris-kernel@axis.com, Haavard Skinnemoen <hskinnemoen@atmel.com>, linux-ia64@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, Jeff Dike <jdike@addtoit.com>, linux-parisc@vger.kernel.org, Chris Zankel <chris@zankel.net>, linux-arch@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463795968-1703548383-1285610489=:2416
Content-Type: TEXT/PLAIN; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable



On Mon, 27 Sep 2010, Tony Luck wrote:

> On Wed, Sep 8, 2010 at 11:14 AM, Thomas Gleixner <tglx@linutronix.de> wro=
te:
> > =A0The following architectures are still using __do_IRQ():
> >
> > =A0alpha, cris, ia64, h8300, m32r, m68knommu, parisc, um
>=20
> Thomas,
>=20
> I (belatedly) took a look at fixing ia64 ... but I've run into a small sn=
ag.
> The __do_IRQ() routine makes a call to:
>=20
>  desc->chip->end(irq);
>=20
> while neither of the "handle_level_irq()" nor "handle_edge_irq()"
> functions do this.
>=20
> On ia64 iosapic_end_level_irq() call iosapic_eoi() for me. Without it
> my system hangs during boot (with some driver timeout complaining
> about dropped interrupts).
>=20
> Is the omission of desc->chip->end(irq); deliberate? In which case
> I need to find another place to call iosapic_eoi(). Or is it accidental?

No, it's deliberate. The solution is to use the correct flow handler
for your device. We have currently several flow handlers implemented:

    handle_level_irq
	{
		if (chip->mask_ack)
			chip->mask_ack()
		else {
		     chip->mask();
		     if (chip->ack)
		     	chip->ack();
		}

		....

		chip->unmask();
	}

    handle_edge_irq
	{
		chip->ack()

		...
	}

    handle_simple_irq
	{
		...
	}

    handle_fasteoi_irq
	{
		...
		chip->eoi();
	}

    handle_percpu_irq
	{=09
		if (chip->ack)
		     	chip->ack();
	=09
		if (chip->eoi)
		     	chip->eoi();
	}

Note, that handle_percpu_irq does not take the irq_desc->lock.

So the trick is to select the matching handler and have separate irq
chip implementations if necessary.

Hope that helps.

Thanks,

	tglx

---1463795968-1703548383-1285610489=:2416--
