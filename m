From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 23 Jun 2003 22:43:05 +0000
Subject: 2.5 bk tree broken?
Message-Id: <marc-linux-ia64-105640820432133@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I did a "bk pull" from

http://lia64.bkbits.net:8080/linux-ia64-2.5

a few minutes ago, and was surprised when BitKeeper
complained about lots of merge collisions (the bk tree
into which I pulled hasn't even had a "bk edit" run in
it, let alone any changes checked in).

Since I'm a neophyte at BK, I tried my usual fix (remove
the whole tree, and run "bk clone" again).  This succeeded
without any reported errors, but time seems to have gone
backwards. The tree I now see is missing some stuff that
was checked into 2.5.72 (e.g fixes to include/asm-ia64/mca.h
and arch/ia64/kernel/mca.h for cleaner handling of INIT
events).

The Web interface to BK says the newest changeset in this
tree was applied 5 weeks ago.

-Tony
