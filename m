From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 11 Jul 2003 00:44:00 +0000
Subject: Re: clone testcases in LTP
Message-Id: <marc-linux-ia64-105788431717061@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105778639326638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105778639326638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 11 Jul 2003 10:35:12 +1000, Ian Wienand <ianw@gelato.unsw.edu.au> said:

  Ian> And that you pass the bottom of the stack, not the top?

Yes.

  Ian> Also, are there explicit alignment requirements?

Not from the kernel per se.

  Ian> I thought it needed to be aligned to page size (or maybe it was
  Ian> 16 bytes).

It the memory stack pointer has to be 16-byte aligned and the
register-backing store pointer has to be 8-byte aligned, as per
architecture/software conventions.

  Ian> And should the stack size be at a minimum ~8K, to allow enough
  Ian> room for register stack?

The kernel doesn't care about the stack size.  If you can live with 4KB,
fine.

  Ian> I have noticed a problem from the LTP tests.  Either I'm doing
  Ian> something wrong (likely related to my assumptions above) or there is
  Ian> something wrong.

It's entirely possible something is wrong (that's almost always
true).

  Ian> See clone2.c below.

Time to clarify my role (once again): I'm currently playing maintainer
of the ia64 linux tree.  That doesn't mean I fix or investigate all
bugs that come along.  If something is broken or not working as
expected then someone who cares should investigate.

It should be trivial for anyone who cares to reproduce this with the
Ski simulator.  This is exactly the type of questions that can be
solved very easily with a simulator.

	--david
