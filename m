From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 02 Jul 2003 01:43:33 +0000
Subject: Early printk is Gone....???
Message-Id: <marc-linux-ia64-105711058824791@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


If I clone David's 2.5 tree (or use Linus's tree, same difference)
CONFIG_IA64_EARLY_PRINTK is inoperative -- the code to do the work
just isn't in the tree.

As it's really useful to have this functionality, can it be added back
in, please?  Possibly somewhere in arch/ia64 so other architectures
don't have to see it (it used to be in kernel/printk)

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.
