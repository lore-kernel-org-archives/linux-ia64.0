From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 04 Aug 2003 17:37:39 +0000
Subject: milstone reached: ia64 linux builds out of Linus' tree
Message-Id: <marc-linux-ia64-106001867501939@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

As of this morning, Linus's current bk tree
(http://linux.bkbits.net:8080/linux-2.5) builds and works out of the
box for ia64!

Thanks to everybody who helped make this happen.  In particular,
thanks to Andrew Morton and Christoph Hellwig for their efforts, and
Andy Grover for a last-minute ACPI patch!

For maximum performance/stability, I'd still recommend to use the
ia64-specific patches, but for someone who needs to build bleeding
edge kernels for multiple architectures, being able to use Linus' tree
should make it a lot easier to include ia64 in their regular testing
etc.

Now that Linus' tree works for ia64, the next question is how we can
keep it that way.  I think it would be useful to have someone setup a
cron job which does daily builds/automated tests off of Linus tree.
If something breaks, the person doing this could perhaps come up with
a minimal patch which gets Linus' tree to build again (and submit a
patch to the appropriate maintainer, with cc to the linux-ia64 list).
I plan on continuing to put out roughly monthly ia64-specific patches
and during those normal cycles, I'd then integrate the "quick fix up"
patches as needed.  Does this sound reasonable?  Anybody want to
volunteer for this "Linus watchdog" role?

	--david
