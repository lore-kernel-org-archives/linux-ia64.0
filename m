From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 02 Aug 2002 06:04:29 +0000
Subject: Re: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905882@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905851@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905851@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 29 Jul 2002 19:36:12 -0700, "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp> said:

  >> Now iosapic.c allocates an ia64 interrupt vector for each
  >> possible _PRT entry.  So iosapic allocates vectors to unpopulated
  >> PCI slots.  This patch fixes the behavior and only allocates
  >> vectors for existing pci_dev only.

Seems reasonable.

  >> Now the ia64_alloc_irq() routine is somewhat(?) broken and panics
  >> if there are more than 183 distinct entries for interrupts.  This
  >> is easily broken with huge configuration servers.

Well, ia64_alloc_irq() does what it was designed to do, so it can't
be broken. ;-)

But yes, on large machines, it's not what you want.

The patch basically looks fine to me, except for some naming issues.
We now have vectors, global vectors, global system interrupts (GSIs),
irq numbers, and what not.  This is confusing and hard to maintain.
We should settle on a consistent set of names (hopefully something
consistent with Linux, ACPI spec, and PCI spec).  I tried to do this a
while ago (see big comment at the beginning of iosapic.c), but the
picture described there is incomplete for large machines and doesn't
do a good job at integrating with ACPI lingo.  Anyone want to take a
stab?

	--david

