From: "Jim Hull" <jim.hull@hp.com>
Date: Mon, 07 Apr 2003 23:30:28 +0000
Subject: RE: [Linux-ia64] spin_unlock() problem
Message-Id: <marc-linux-ia64-105590723705433@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705414@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705414@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David wrote:

> Oops, sorry, I got it exactly backwards. ;-(
> So much for giving a "quick" reply...

Right.  In Jes's example:

cpu1()
{
   spin_lock(&bleh);
   *a = foo;
   spin_unlock(&bleh);
   *b = bar;
}

cpu2()
{
   if (*b = bar)
      boink(*a);
}

For cpu1(), there are 2 ways to guarantee the store to *b is made
visible after to the store to *a:

1) Execute an "mf" instruction between them (probably via a change to
the spin_unlock macro), or

2) Make sure the store to *b is a release store (probably by making its
type "volatile").

There's also a problem in cpu2().  At present, there's nothing
guaranteeing the ordering of the loads of *b and *a.  Again, there are 2
ways to guarantee this:

1) Add an explicit "mf" between them (no simple change to a spin macro
will help here), or

2) Make sure the load of *b is an acquire load (probably by making its
type "volatile").

Note that change number (2), making *b volatile, fixes both problems, so
it is what I would recommend.  Of course this is probably a much harder
change, perhaps to architecture-independent code, instead of just
"fixing" an architecture-dependent macro, but it is the only thing that
will fix both halves of the problem.

 -- Jim


