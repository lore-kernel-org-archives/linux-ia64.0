From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 04 Aug 2003 23:35:32 +0000
Subject: Re: milstone reached: ia64 linux builds out of Linus' tree
Message-Id: <marc-linux-ia64-106004038224953@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106001867501939@msgid-missing>
In-Reply-To: <marc-linux-ia64-106001867501939@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 5 Aug 2003 09:06:18 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

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

  Peter> We can do this.  We're tracking Linus's tree anyway for the work we're
  Peter> doing.

Excellent!

  Peter> We'd probably do daily automated builds to check that the kernel
  Peter> still compiles cleanly for HPSIM, DIG, and ZX1, but test only weekly.

Sounds reasonable.  Except doing a boot/halt cycle on the simulator
should be easy to automate, no?  The simulator can actually catch a
surprising number of problems.

  Peter> If you have anyu specific configuration options you think should be
  Peter> included, let us know.

Nothing in particular, though it would be good to cover UP, MP, 16,
and 64KB page sizes (not in all permutations, of course).

Thanks,

	--david
