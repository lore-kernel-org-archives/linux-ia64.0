From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 30 Aug 2002 05:02:35 +0000
Subject: [Linux-ia64] kdb/ia64 patch for 2.5.xx
Message-Id: <marc-linux-ia64-105590701906001@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith told me that he has no plans of putting out a 2.5-based kdb
patch so I took the 2.4 patches and hacked them up to make them work
with 2.5.  The resulting patch is available at:

  ftp://ftp.hpl.hp.com/pub/linux-ia64/kdb-ia64-2.5.32.diff.gz

No warranties, no support, etc., but I did use it for debugging via
VGA console + PS/2 keyboard, via legacy-free serial port, and via the
HP Ski simulator.  I didn't try the USB keyboard support.

Enjoy,

	--david

PS: An ia64 patch for 2.5.32 will be out shortly...

