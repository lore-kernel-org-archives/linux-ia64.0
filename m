From: Matt Mackall <mpm@selenic.com>
Date: Fri, 08 Apr 2005 23:15:43 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random problem on 2.6.12-rc1)]
Message-Id: <20050408231543.GF3174@waste.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 08, 2005 at 04:01:11PM -0700, David Mosberger wrote:
> >>>>> On Fri, 8 Apr 2005 15:49:13 -0700, Matt Mackall <mpm@selenic.com> said:
> 
>   >> Yes, that'll give the right result for fls(-1).  But what'll it
>   >> give for fls(-2)?
> 
>   Matt> There's no such thing, it takes an unsigned long. There's two
>   Matt> problems:
> 
>   Matt> input generic_fls ia64_fls exponent (with bias +65535) 0000000
>   Matt> 0 -65535 0 0000001 1 0 65535 1000000 32 31 65566
> 
>   Matt> So there's the off-by-one problem. And then there's the huge
>   Matt> discontinuity at 0. Trouble is the bias is 65535 rather than
>   Matt> 65536 so there's no masking trick that works. We could instead
>   Matt> to do exp((x*2)+1).
> 
> ia64_fls() returns an undefined result for 0 and, as you observed,
> returns bit numbers starting from 0.  Also, ia64_fls() works on full
> 64-bit values, not just 32 bits.
> 
> Fixing fls() is trivial:
> 
> static inline int
> fls (int x)
> {
> 	if (!x)
> 		return 0;
> 	return ia64_fls((unsigned int) x) + 1;
> }

I was trying desperately to avoid the branch, as I understand there
are issues there on IA64. 

-- 
Mathematics is the supreme nostalgia of our time.
