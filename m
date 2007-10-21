From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sun, 21 Oct 2007 04:43:31 +0000
Subject: Re: [IA64] Reduce __clear_bit_unlock overhead
Message-Id: <200710211443.31445.nickpiggin@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0710182037220.25820@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710182037220.25820@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 19 October 2007 21:12, Christoph Lameter wrote:
> On Fri, 19 Oct 2007, Nick Piggin wrote:
> > Of course, we can avoid the fence altogether on x86 as well, because
> > it simply isn't needed for release semantics.
>
> So we can generally switch to using wmb there?

Not for asm-generic/. But for x86, we don't anything actually
(because writes are ordered). I sent a patch to Linus for this
earlier -- he hasn't taken it yet, but I will ensure it gets
merged before 2.6.24.

Also I didn't get a chance to send out the other patches before,
because of issues with my net connection. Will do so now.

>
>
>
> __clear_bit_unlock: A write barrier is sufficient for release semantics
>
> Switch the smb_mb that causes a fence instruction to be issued on x86
> to a write barrier which issues no instruction on x86.
>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>
> Index: linux-2.6/include/asm-generic/bitops/lock.h
> =================================> --- linux-2.6.orig/include/asm-generic/bitops/lock.h	2007-10-19
> 04:08:58.000000000 -0700 +++
> linux-2.6/include/asm-generic/bitops/lock.h	2007-10-19 04:09:17.000000000
> -0700 @@ -37,7 +37,7 @@ do {					\
>   */
>  #define __clear_bit_unlock(nr, addr)	\
>  do {					\
> -	smp_mb();			\
> +	smp_wmb();			\
>  	__clear_bit(nr, addr);		\
>  } while (0)
