From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 16 Aug 2001 00:25:18 +0000
Subject: Re: [Linux-ia64] rwlock and atomic_sub on ia64
Message-Id: <marc-linux-ia64-105590698805085@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805063@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805063@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 15 Aug 2001 15:29:19 -0700, KOCHI Takayoshi <t-kouchi@mvf.biglobe.ne.jp> said:

  Kochi> This is because atomic_sub is actually a macro defined in
  Kochi> asm-ia64/atomic.h and it compares value against negative values
  Kochi> to get optimized code.

  Kochi> So, four comparison against negative numbers makes four warnings
  Kochi> for the single atomic_sub.

  Kochi> Here is the quote of atomic_sub

  Kochi> #define atomic_sub_return(i,v)						\
  Kochi> ((__builtin_constant_p(i) &&					\
  Kochi> (    ( i =  1) || ( i =  4) || ( i =  8) || ( i = 16)	\
  Kochi> || ( i = -1) || ( i = -4) || ( i = -8) || ( i = -16)))	\
  Kochi> ? ia64_fetch_and_add(-(i), &(v)->counter)			\
  Kochi> : ia64_atomic_sub(i, v))

  Kochi> #define atomic_sub(i,v)		atomic_sub_return((i), (v))

That's correct.  We could fix this with appropriate casting and then
you could use fetchadd1 to increment unsigned variables by 224, 240,
252, 255.  However, getting this 100% is rather tricky and I'm not
sure I want to play with this in the 2.4 series.  For now, I'd
recommend to just live with the warning (it's harmless, other than
being annoying).

	--david

