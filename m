From: Tony Luck <tony.luck@gmail.com>
Date: Wed, 27 May 2015 17:37:01 +0000
Subject: Re: [PATCH 06/16] ia64: fix up obsolete cpu function usage.
Message-Id: <CA+8MBbLiSWmptfsWO8zmkquq7KsojThU7m7sLxhbwLX1co0YGw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425296150-4722-1-git-send-email-rusty@rustcorp.com.au>
	<1425296150-4722-6-git-send-email-rusty@rustcorp.com.au>
	<CA+8MBbJiQeP3SHoqM+D0v6q5oOvaDgwr7RnFNJZ=TS8oPpoa5A@mail.gmail.com>
	<87mw0qn7h0.fsf@rustcorp.com.au>
In-Reply-To: <87mw0qn7h0.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Tue, May 26, 2015 at 6:18 PM, Rusty Russell <rusty@rustcorp.com.au> wrote:

> cpumask_test_cpu() doesn't take volatile, unlike the obsoleted
> cpu_isset.  The only place ia64 really cares is the spin waiting for a
> bit; udelay() is probably a barrier but insert rmb() to be sure.

Good to be sure ... but cpumask_test_cpu() simply calls test_bit() ...
and 2 out of 3 versions of that function throw "volatile" back into the
mix: :-)

Global definition: test_bit

  File                            Line
0 include/asm/bitops.h            334 test_bit (int nr, const volatile
void *addr)
1 asm-generic/bitops/non-atomic.h 103 static inline int test_bit(int
nr, const volatile unsigned long *addr)
2 asm-generic/bitops/atomic.h      16 static __always_inline int
test_bit(unsigned int nr, const unsigned long *addr)
