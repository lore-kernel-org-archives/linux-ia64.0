From: "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com>
Date: Thu, 06 Dec 2001 23:56:20 +0000
Subject: [Linux-ia64] mprotect problem
Message-Id: <marc-linux-ia64-105590698805634@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We are seeing an apparent problem with mprotect on Itanium.  We have seen
the problem
on two different machines, one running RedHat 7.1 (Seawolf)  [2.4.3-12smp]
and one
running Turbolinux [2.4.1-010131-8smp].

The mprotect is called from user space, as part of the implementation of a 
distributed virtual shared memory system that uses the virtual
memory mechanism to implement a shared address space between two or more
nodes.

The code works correctly under RedHat 7.1 for IA32 (and a variety of other
OS'es and platforms, so
we feel that there aren't coding errors, although maybe there is some
slightly different
way to use mprotect on Itanium (additional parameters, or flags?)?.

The problem we see is this:

During the course of running the user's program on top of our DVSM, the
program touches 
a "shared" page that has been mprotect'ed against reading and writing
previously because it is not
up-to-date with respect to the same page on other nodes in the system.  The
access faults,
our SEGV handler is called, we do the appropriate message passing operations
to 
make the data on the page consistent and up-to-date, then do an mprotect
allowing 
READ and WRITE this time, and return from the SEGV handler.  At this point,
the original instruction
(a READ) is restarted and immediately faults, causing control to go to the
SEGV handler 
again.  This time, since we know the page is up-to-date, we do nothing and
return, the 
instruction is again re-started, again faults, again jumps to the SEGV
handler . . . an infinite
loop.

The interesting thing is that this particular user code fails at random
points, sometimes working
correctly at points where it failed before.  We have never seen the code
work correctly all the way
through, though.  It always fails very soon after it begins, just at
different points on different runs.
We theorized that this was a timing problem, such that it just took some
time for mprotect to 
take effect, so we put in 10-millisecond delays after each mprotect, but
this really changed nothing.

One potential clue would be that the code is a pthreads program, and
multiple threads are 
running while one thread is doing the mprotect, and these machines are both
dual-processor machines.

We would appreciate any help that anyone can give.

Jay

Jay Hoeflinger, jay.p.hoeflinger@intel.com
KAI Software, A Division of Intel Americas, Inc., http://www.kai.com
Phone 217/356-2288, Direct 217/356-5052 x 140, Fax 217/356-5199



