From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 Apr 2004 01:03:38 +0000
Subject: kernel update (relative to 2.6.5)
Message-Id: <200404140103.i3E13cB0004406@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At long last, the ia64-patch for 2.6.5...
It's in the usual place:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.6/

in file

 linux-2.6.5-ia64-040413.diff.gz

There is one significant change: I decided to fix signal delivery so
signal handlers are forced to be invoked with little-endian
byte-order.  My position in the past has been that if you turn-on
big-endian byte-order, you're on your own.  Indeed, if you happened to
get a signal in big-endian byte-order, you were pretty much guaranteed
to get a SIGSEGV.  I decided to fix this particular issue because I
found some "legacy" code which was taking advantage of big-endian
byte-order and so that code ran the risk of crashing if a signal
occurred.  Having said that, you're still mostly on your own with
big-endian byte-order.  In particular, things could go horribly wrong
if pointers or frame-related values (such as the return-address) were
stored in big-endian byte-order.  On the other hand, if you turn on
big-endian mode temporarily, say, in a leaf-routine doing some
calculations, you should be OK.

Also, I decided to change the extended config-space addressing support
in SAL such that we can avoid version number checking---that's just
too fragile and has been a repeated source of trouble and lost time.

Oh, there is a big perfmon update with some important fixes.  See the
ChangeLog entry here for details:

 http://linux.bkbits.net:8080/linux-2.5/cset@eranian@hpl.hp.com|ChangeSet|20040409002153|03271

Enjoy,

	--david
