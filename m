From: Andi Kleen <ak@muc.de>
Date: Wed, 09 Mar 2005 23:01:22 +0000
Subject: Re: Page Fault Scalability patch V19 [1/4]: pte_cmpxchg and
Message-Id: <m1y8cwv2yl.fsf@muc.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050309201324.29721.28956.sendpatchset@schroedinger.engr.sgi.com>
	<20050309201329.29721.1860.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20050309201329.29721.1860.sendpatchset@schroedinger.engr.sgi.com> (Christoph
 Lameter's message of "Wed, 9 Mar 2005 12:13:29 -0800 (PST)")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Christoph Lameter <clameter@sgi.com> writes:
>
> Atomic operations may be enabled in the kernel configuration on
> i386, ia64 and x86_64 if a suitable CPU is configured in SMP mode.
> Generic atomic definitions for ptep_xchg and ptep_cmpxchg
> have been provided based on the existing xchg() and cmpxchg() functions
> that already work atomically on many platforms. It is very

I'm curious - do you have any micro benchmarks on i386 or x86-64 systems
about the difference between spin_lock(ptl) access; spin_unlock(ptl);
and cmpxchg ? 

cmpxchg can be quite slow, with bad luck it could be slower than 
the spinlocks.

A P4 would be good to benchmark this because it seems to be the worst
case.

-Andi
