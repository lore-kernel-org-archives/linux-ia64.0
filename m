From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 04 Aug 2003 23:06:18 +0000
Subject: milstone reached: ia64 linux builds out of Linus' tree
Message-Id: <marc-linux-ia64-106003847823287@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106001867501939@msgid-missing>
In-Reply-To: <marc-linux-ia64-106001867501939@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

David> Now that Linus' tree works for ia64, the next question is how
David> we can keep it that way.  I think it would be useful to have
David> someone setup a cron job which does daily builds/automated
David> tests off of Linus tree.  If something breaks, the person doing
David> this could perhaps come up with a minimal patch which gets
David> Linus' tree to build again (and submit a patch to the
David> appropriate maintainer, with cc to the linux-ia64 list).  I
David> plan on continuing to put out roughly monthly ia64-specific
David> patches and during those normal cycles, I'd then integrate the
David> "quick fix up" patches as needed.  Does this sound reasonable?
David> Anybody want to volunteer for this "Linus watchdog" role?

We can do this.  We're tracking Linus's tree anyway for the work we're
doing.  

  We'd probably do daily automated builds to check that the kernel
still compiles cleanly for HPSIM, DIG, and ZX1, but test only weekly.

If you have anyu specific configuration options you think should be
included, let us know.


--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.
