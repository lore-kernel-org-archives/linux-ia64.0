From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 09 Jun 2016 17:36:40 +0000
Subject: Re: [RFC 10/12] x86, rwsem: simplify __down_write
Message-Id: <20160609173640.GX30154@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160603223417.GB3892@twins.programming.kicks-ass.net>
 <1454444369-2146-1-git-send-email-mhocko@kernel.org>
 <1454444369-2146-11-git-send-email-mhocko@kernel.org>
 <20160203081016.GD32652@gmail.com>
 <20160603161339.GC3693@twins.programming.kicks-ass.net>
 <29355.1465483258@warthog.procyon.org.uk>
In-Reply-To: <29355.1465483258@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Howells <dhowells@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Paul E. McKenney" <paulmck@us.ibm.com>, Jason Low <jason.low2@hpe.com>

On Thu, Jun 09, 2016 at 03:40:58PM +0100, David Howells wrote:
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > Blergh; so looking at more asm there's still a few tricks we cannot do.
> > So while overall size is down, some paths do end up more expensive. (It
> > typically boils down to creative use of condition flags, which is very
> > hard in C)
> 
> It can be done using ISO __atomic_fetch_add() and suchlike.

(ISO-C11, ISO as such is a bad abbreviation I think)

Maybe, but we're almost there with __GCC_ASM_FLAG_OUTPUTS__.

atomic_long_add_negative() can be made to do inc;j(n)s for __down_read.

the try_cmpxchg family you wanted to add independent from the ISO-C11
bits can do the cmpxchg-j(n)z for __down_{read,write}_trylock.

That only leaves us wanting an atomic_long_fetch_add_negative() for
__up_{read,write}().

Although I suppose, for this to be of use for our weakly ordered
friends, we need _relaxed versions of all that (so that _acquire and
_release variants are generated).


