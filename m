From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 30 Jan 2003 04:39:56 +0000
Subject: [Linux-ia64] Re: Confused about fsystemcalls
Message-Id: <marc-linux-ia64-105590709805777@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805775@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805775@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 30 Jan 2003 15:31:19 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Worked it out -- one needs to call the mygetpid() function
  Peter> twice, once before the timing stuff, and once during, so we
  Peter> don't count the time to get the gate page into the TLB and
  Peter> into the cache.

Yes, that makes a big difference.  Here is what I see for getppid() on
a McKinley:

	getppid cycles: 1410 79 56 54 54 54 54 54 54 54

(I just added getppid() and I also added code to patch over the
McKinley E9 workaround on CPUs that don't need it.)

  Peter> Timings are now 177 cycles for the mygetpid() routine as
  Peter> opposed to 570 for glibc (all on Itanium 1),

Ah, that's much better.

  Peter> and we're now working on gettimeofday().

Cool.  I assume you're doing this based on the lock-free version that
Andrew Morton has in his latest patch?

	--david


