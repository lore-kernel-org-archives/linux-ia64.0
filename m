From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 05 Dec 2002 08:13:59 +0000
Subject: [Linux-ia64] 2.5.50+ patch for the impatient...
Message-Id: <marc-linux-ia64-105590709805503@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

For those of you who're impatiently waiting for a 2.5.xx update, I put
a preliminary patch at:

  ftp://ftp.hpl.hp.com/pub/linux-ia64/patch-2.5.50-1.968-lia64.diff.gz

The patch is relative to revision 1.968 of Linus' bitkeeper tree
(which is 2.5.50 with a bunch of additional patches).  Only the Ski
simulator has been tested.  Kernel modules are definitely broken at
the moment, since the ia64-part of the in-kernel module-loader is
missing (I don't use modules myself and in any case it may be better
to wait until things have settled down a bit; it looks like Rich
Henderson has convinced Rusty to make modules effectively shared
objects).

I hope to have a more complete update by the time Linus gets ready to
relese 2.5.51.  So if you're not urgently waiting for 2.5.50, you
might want to wait till then.

Enjoy,

	--david

