From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Nov 2004 01:10:44 +0000
Subject: updated libm available
Message-Id: <16802.36372.32399.861551@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thought this might be of interest to some folks on these lists: we
recently developed a glibc patch which updates the libm with code
based on the latest Intel libm release (which is v2.1).  The code
currently in glibc is based on v1.4 and the Intel libm code has been
improved a lot since then (some functions run 5 times (!) faster than
before, many functions have been added, precision has improved, etc.).

For details, see this mail:

  http://sources.redhat.com/ml/libc-hacker/2004-11/msg00045.html

There is a gnumeric spreadsheet attached to this mail which contains a
(rough) summary of the speed improvements.

I hope that the libm update will make it into the official glibc
sources soon, but thought it would be good to raise awareness for the
existence of this much improved libm.

	--david
