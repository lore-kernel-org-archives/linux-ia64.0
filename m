From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 30 Jan 2003 04:31:19 +0000
Subject: [Linux-ia64] Re: Confused about fsystemcalls
Message-Id: <marc-linux-ia64-105590709805776@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805775@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805775@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Thu, 30 Jan 2003 11:07:51 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:
Peter> The mygetpid() call appears to return the correct value.

Peter> Our figures show over an average of ten runs: --- glibc
Peter> getpid() takes 579 cycles, stddev 24 --- mygetpid takes 1468
Peter> cycles, stddev 286

David> Have you tried on a McKinley?  The numbers you quote for the
David> standard getpid() look like for Merced.  I never tried on
David> Merced, though I don't know of why it shouldn't work fast, off
David> hand.


Worked it out -- one needs to call the mygetpid() function twice, once
before the timing stuff, and once during, so we don't count the 
time to get the gate page into the TLB and into the cache.

Timings are now 177 cycles for the mygetpid() routine as opposed to
570 for glibc (all on Itanium 1), and we're now working on
gettimeofday().


Peter C

