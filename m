From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 06 Sep 2000 01:30:08 +0000
Subject: Re: [Linux-ia64] [PATCH] fix casting problem in megaraid driver
Message-Id: <marc-linux-ia64-105590678205454@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Andrew,

>>>>> On Tue, 5 Sep 2000 10:50:38 -0700, aip@turbolinux.com said:

  Andrew> This patch fixes bug where mbox's pointer was cast to
  Andrew> integer, caused segfault.

The patch looks a bit suspicious to me.  I'm not familiar with the
megaraid driver, but looking at the relevant code, it's clear that
"paddr" really is a 32 bit PCI address (it gets written to the device
as a sequence of four byte writes), so changing it to u64 clearly
isn't 100% correct.

Now, looking at the code that calls the routine in question:

 mega_register_mailbox (megaCfg, virt_to_bus ((void *) &megaCfg->mailbox64));

we find that, yuck, this is another driver that hasn't been updated
for the PCI DMA interface.  Not much point in hacking around in this
driver until this gets rectified...

Note that the virt_to_bus() and bus_to_virt() macros have been
obsoleted by the PCI DMA interface and will be removed from the kernel
at some future point (I'm tempted to do this now so we'll discover
right away which drivers need cleaning up).

Can you ask the megaraid maintainers to update their driver to use the
PCI DMA interface?

	--david

