From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 24 Jun 2005 20:36:25 +0000
Subject: Re: [patch] Memory Error Handling Improvement
Message-Id: <17084.28361.563291.602215@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 24 Jun 2005 15:11:09 -0500 (CDT), Russ Anderson <rja@sgi.com> said:

  Russ> Testing with error injection showed a significant number of
  Russ> cases where the MCA surfaced early in the interrupt routine,
  Russ> even though the load of the bad data was launched from a user
  Russ> process.  Adding the second condition to look for these cases
  Russ> allowed them to be recovered.  Analysis of the recovered MCA
  Russ> records showed 7-10% of the recoverys were this condition,
  Russ> when running the error recovery code with other activity that
  Russ> caused interrupts.

  Russ> Previously, if the MCA surfaced while the cpu was in privilage
  Russ> mode the code would not try to recover.  This change adds a
  Russ> second condition, to see if the kernel is early in the
  Russ> interrupt routine.  It does this by checking the instruction
  Russ> range.  As Hidetoshi Seto points out, the check should also
  Russ> make sure the interrupted process was in user mode.  That has
  Russ> been added to the patch and tested.

Sorry, but this doesn't make any sense to me.  If an application
spends a lot of time handling TLB faults or unaligned access faults,
it's very likely the MCA will hit in those handlers and your patch
will not help at all.  Furthermore, if MCA delivery timing changes for
some reason, the user-triggered MCA might show up much later, i.e.,
pretty much anywhere in the kernel no?

Isn't there a more reliably method to handle this?  What if you just
_assumed_ that MCAs are triggered by user-level (unless you can prove
that it was kernel-only memory, perhaps).

	--david

