From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 25 Sep 2002 16:01:16 +0000
Subject: [Linux-ia64] Re: IOSAPIC cleanup and bugfixes patch
Message-Id: <marc-linux-ia64-105590701906050@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Now that ia64 has been switched over to using the ACPI PCI irq code in
the the 2.5 tree, I'm wondering whether we shouldn't just make the
Linux irq numbers equal to the GSIs.  Both are (relatively) arbitrary,
small numbers and making them equal would simplify things a bit.  The
only downside would be that the Linux irq numbers would no longer be
equal to the IA-64 vectors, so that the irq->vector translation would
have to go through a table-lookup even on "small" systems.  The
performance effect of this should be completely trivial (i.e., I bet
it's not measurable).

Comments?  Takers? ;-)

	--david

