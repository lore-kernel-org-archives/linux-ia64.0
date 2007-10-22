From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 22 Oct 2007 09:01:39 +0000
Subject: Re: [IA64] Effective __clear_bit_unlock V2
Message-Id: <471C66F3.2060400@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0710191050520.31589@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710191050520.31589@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:

> --- linux-2.6.orig/include/asm-ia64/bitops.h	2007-10-19 04:05:38.000000000 -0700
> +++ linux-2.6/include/asm-ia64/bitops.h	2007-10-19 10:50:34.000000000 -0700

...

>  /**
> + * __clear_bit_unlock - Non-atomically clear a bit with release
> + */
> +static __inline__ void
> +__clear_bit_unlock (int nr, volatile void *addr)
> +{
> +	barrier();
> +	__clear_bit(nr, addr);
> +}
> +
> +/**

Well, the "old" __clear_bit() went like this:

__clear_bit (int nr, volatile void *addr)
{
	*((__u32 *) addr + (nr >> 5)) &= ~(1 << (nr & 31));
}

(I really do not see why "addr" is a pointer to a volatile stuff.
If it really can change independently from the current thread of
control, then a non atomic operation is not much useful.
Luckily :-) "addr" is casted into a pointer to a non volatile stuff.)

It has been changed into:

__clear_bit (int nr, volatile void *addr)
{
        volatile __u32 *p = (__u32 *) addr + (nr >> 5);
        __u32 m = 1 << (nr & 31);
        *p &= ~m;
}

I guess because of __clear_bit_unlock() needs only.
__set_bit() still keeps its ".rel" / ".acq" free store / load instruction.

__set_bit (int nr, volatile void *addr)
{
        *((__u32 *) addr + (nr >> 5)) |= (1 << (nr & 31));
}

Note that most of the __clear_bit() / __set_bit() usage are some bit map
or indicator manipulations. They do not need any ".rel" / ".acq"
semantics.

Let's put back the old ".rel" / ".acq" free __clear_bit() and
let's use specific variant of ...clear_bit() where ".rel" semantics
is requred.
Let's avoid adding ".acq" semantics to ...clear_bit() where is is not
required.


Zoltan
