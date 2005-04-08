From: Matt Mackall <mpm@selenic.com>
Date: Fri, 08 Apr 2005 22:49:13 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random problem on 2.6.12-rc1)]
Message-Id: <20050408224913.GD3174@waste.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 08, 2005 at 11:02:47AM -0700, Andrew Morton wrote:
> Matt Mackall <mpm@selenic.com> wrote:
> >
> > One wonders if:
> > 
> >   return ia64_getf_exp(d) & 0x3f;
> > 
> >  is the right fix.
> 
> Yes, that'll give the right result for fls(-1).  But what'll it give for
> fls(-2)?

There's no such thing, it takes an unsigned long. There's two problems:

input      generic_fls   ia64_fls   exponent (with bias +65535)
0000000              0    -65535        0
0000001              1         0    65535
1000000             32        31    65566

So there's the off-by-one problem. And then there's the huge
discontinuity at 0. Trouble is the bias is 65535 rather than 65536 so
there's no masking trick that works. We could instead to do
exp((x*2)+1).

-- 
Mathematics is the supreme nostalgia of our time.
