From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sun, 21 Dec 2003 10:51:46 +0000
Subject: kernel update (relative to v2.6.0)
Message-Id: <marc-linux-ia64-107200392525619@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just released a new ia64 patch that goes on top of v2.6.0.
It's in the usual place:

	ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.6/

in file linux-2.6.0-ia64-031221.diff.bz2

The biggest change is the large MCA updates by Keith, Tony and Bjorn.
Oh, and for all you workstation nuts, I threw in a patch to get the
ipaq USB module to work!  (Now if only I could get evolution 1.4 to
play along, so I could actually synchronize my ipaq with my
zx2000... ;-)

Detailed changelog is here:

  http://lia64.bkbits.net:8080/linux-ia64-2.5/ChangeSet@1.1496.2.37..1.1510

The patch has checked out on zx2000, rx5670 (4-way) and on the Ski
simulator.  As usual, your mileage may vary.

Oh, and before you flood me with patches, I don't expect to work much
on the kernel until next year.

Happy Holidays!

	--david
