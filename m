From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 15 Apr 2002 22:18:22 +0000
Subject: [Linux-ia64] kernel update relative to 2.5.8
Message-Id: <marc-linux-ia64-105590701905456@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A new ia64 patch is now at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/ in file:

	linux-2.5.8-ia64-020415.diff.gz

The ia64 changes since the 2.5.8-pre3 patch are listed below.

Note: I'm planning to dump the qla2x00.c driver in the next patch,
unless someone volunteers to clean up the driver and submit it into
the official tree.

	--david

ChangeSet@1.489.1.1, 2002-04-15 13:40:58-07:00, davidm@wailua.hpl.hp.com
  ia64: Jes's changes have been accepted by Linus, so we can now switch
  back to the qla1280 driver in Linus's tree.

ChangeSet@1.456.5.5, 2002-04-13 00:13:12-07:00, davidm@wailua.hpl.hp.com
  ia64: Switch i460 AGP into coherent DMA mode (required by ia64 linux
  to avoid illegal attribute aliasing).  Fix i460 readback so it
  doesn't get optimized away by the compiler.  Fix up formatting
  (mostly whitespace).

ChangeSet@1.456.5.4, 2002-04-12 16:31:14-07:00, bjorn_helgaas@hp.com
  [PATCH] ia64: Check for 460gx before applying workaround.

ChangeSet@1.456.5.3, 2002-04-12 16:30:18-07:00, bjorn_helgaas@hp.com
  [PATCH] ia64: More agpgart cleanup.

ChangeSet@1.456.15.3, 2002-04-12 16:20:45-07:00, davidm@wailua.hpl.hp.com
  ia64: clean up to enable 64KB page size.

ChangeSet@1.456.5.2, 2002-04-11 15:11:26-07:00, davidm@wailua.hpl.hp.com
  ia64: Add AGP support for HP zx1 platform.  Fix physical-address
  calculation.

