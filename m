From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Jun 2003 23:09:50 +0000
Subject: Re: 2.5 bk tree broken?
Message-Id: <marc-linux-ia64-105641006001147@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105640820432133@msgid-missing>
In-Reply-To: <marc-linux-ia64-105640820432133@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Try again.  It looks like the tree should be back to normal.

	--david

>>>>> On Mon, 23 Jun 2003 15:43:05 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> I did a "bk pull" from
  Tony> http://lia64.bkbits.net:8080/linux-ia64-2.5

  Tony> a few minutes ago, and was surprised when BitKeeper complained
  Tony> about lots of merge collisions (the bk tree into which I
  Tony> pulled hasn't even had a "bk edit" run in it, let alone any
  Tony> changes checked in).

  Tony> Since I'm a neophyte at BK, I tried my usual fix (remove the
  Tony> whole tree, and run "bk clone" again).  This succeeded without
  Tony> any reported errors, but time seems to have gone
  Tony> backwards. The tree I now see is missing some stuff that was
  Tony> checked into 2.5.72 (e.g fixes to include/asm-ia64/mca.h and
  Tony> arch/ia64/kernel/mca.h for cleaner handling of INIT events).

  Tony> The Web interface to BK says the newest changeset in this tree
  Tony> was applied 5 weeks ago.

  Tony> -Tony - To unsubscribe from this list: send the line
  Tony> "unsubscribe linux-ia64" in the body of a message to
  Tony> majordomo@vger.kernel.org More majordomo info at
  Tony> http://vger.kernel.org/majordomo-info.html
