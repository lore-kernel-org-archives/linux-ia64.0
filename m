From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Nov 2003 23:21:07 +0000
Subject: sigtramp bug-fix (applies to 2.4 and 2.6)
Message-Id: <marc-linux-ia64-106988919920591@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Laurent Morichetti found a bug in the signal trampoline for which I
just checked in a fix.  The problem was that the trampoline was using
a scratch predicate-register in an unwind-directive.  This was wrong,
because the routine isn't a leaf and that scratch register may get
clobbered by the signal handler.  To work around the problem, simply
switch from using p8 to p1 (that's fine because "pr" is already
saved/restored by the kernel).

For details, see this URL:

  http://lia64.bkbits.net:8080/to-linus-2.5/cset@1.1497

Bjorn, could you apply this patch for 2.4 as well?  If it doesn't
apply, let me know (it should be very close though, apart from a large
fuzz).

BTW: If someone were working on an unwind-info validation tool, that
sure would be useful!

	--david
