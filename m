From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 26 Apr 2004 21:12:38 +0000
Subject: Re: [PATCH] bug w/ shared interrupts
Message-Id: <16525.31558.89699.660763@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1082989740.15656.20.camel@localhost>
In-Reply-To: <1082989740.15656.20.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 26 Apr 2004 08:29:00 -0600, Alex Williamson <alex.williamson@hp.com> said:

  Alex>    I just ran into a bug introduced by cset 1.1371.519.37.

Note that cset numbers are not globally unique.  Since you didn't specify
which repository you used, I'm not sure which cset you're referring to.
To get a globally unique cset id, you can use:

  $ bk changes -k -r1.1371.519.37

I believe you're referring to:

  kaneshige.kenji@jp.fujitsu.com|ChangeSet|20040412205820|04778

Correct?

  Alex> The scenario is a builtin driver is up and running happily.  A
  Alex> module loads for a devices that happens to share the same
  Alex> interrupt vector, in this case a network driver.  The module
  Alex> calls pci_enable_device() as it should, which eventually lands
  Alex> in iosapic_enable_intr().  We then proceed to mask the
  Alex> interrupt and kill the device that's already running.  As a
  Alex> bonus, request_interrupt() doesn't fix the problem because we
  Alex> only call the startup for the interrupt handler on the first
  Alex> action attached to the interrupt.

  Alex>    I think the best way out of this is simply to detect when
  Alex> an action is already attached to a vector and leave it alone.
  Alex> This also prevents interrupts from moving to other cpus (on
  Alex> boxes w/o irq redirection) for no good reason.

Sounds reasonable to me.  I do think that iosapic_enable_intr() is
misnamed now that it actually leaves the interrupt _masked_.  What
it's really doing now is that it asserts that the I/O SAPIC routine is
programmed to a correct/working value.  It would be good to fix that
when changing the corresponding code in drivers/acpi/pci_irq.c.  IIRC,
Bjorn already has patches which touch on that file.  If so, could you
do a rename at the same time, Bjorn?

	--david
