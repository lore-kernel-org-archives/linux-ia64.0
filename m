From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 30 May 2003 16:32:03 +0000
Subject: Re: [Linux-ia64] sigaltstack and ar.bspstore
Message-Id: <marc-linux-ia64-105590723706088@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706086@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706086@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 31 May 2003 00:18:39 +1000, Matt Chapman <matthewc@cse.unsw.edu.au> said:

  Matt> Presumably the result should be the same as the original
  Matt> bspstore.  However, it isn't in the case when the original
  Matt> bspstore is pointing to slot 63 (the RNAT word).  The new
  Matt> bspstore comes out pointing to slot 0 of the next group, and
  Matt> the RNAT bits never get written.  This happens more often then
  Matt> you'd expect, since it seems that current implementations make
  Matt> the optimisation of writing the RNAT word together with the
  Matt> first word of the new group instead of the last word of the
  Matt> old group (sensible because it potentially saves a write).

Yes, I noticed the same in libunwind. ;-/

  Matt> I'd propose that the trampoline code should save bspstore in
  Matt> the sigcontext structure and restore it from there rather than
  Matt> recalculating it.  I can send a patch, but first is there any
  Matt> reason why it shouldn't be done that way?

My preference would be to fix it in a way that preserves binary
compatibility for the sigcontext structure.

	--david

