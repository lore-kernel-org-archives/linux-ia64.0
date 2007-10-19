From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 19 Oct 2007 09:14:34 +0000
Subject: Re: [IA64] Reduce __clear_bit_unlock overhead
Message-Id: <4718757A.9040805@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0710182037220.25820@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710182037220.25820@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You may want to avoid assembly magics:

static __inline__ void
__clear_bit_unlock(int const nr, volatile void * const addr)
{
        volatile __u32 * const m = (volatile __u32 *) addr + (nr >> 5);

        *m &= ~(1 << (nr & 0x1f));
}

GCC compiles volatile loads with ".acq" and stores with ".rel".
E.g. the following program:

int lo = 3;

main()
{
        __clear_bit_unlock(1, &lo);
}

compiles into (NOP-s removed):

4000000000000680 <main>:0b 70 e0 03 00 24       [MMI]       addl r140,r1;;
4000000000000686:       f0 00 38 60 21 00                   ld4.acq r15=[r14]
4000000000000690:       0a 78 f4 1f 2c 22       [MMI]       and r15=-3,r15;;
4000000000000696:       00 78 38 60 23 00                   st4.rel [r14]=r15
40000000000006ac:       08 00 84 00                         br.ret.sptk.many b0;;

Actually, we don't need a load with ".acq". A somewhat less readable code:

static __inline__ void
__clear_bit_unlock(int const nr, void * const addr)
{
        __u32 * const p = (__u32 *) addr + (nr >> 5);

        * (volatile __u32 *) p = *p & ~(1 << (nr & 0x1f));
}

gives you:

4000000000000680 <main>:0b 70 e0 03 00 24       [MMI]       addl r140,r1;;
4000000000000686:       f0 00 38 20 20 00                   ld4 r15=[r14]
4000000000000690:       0a 78 f4 1f 2c 22       [MMI]       and r15=-3,r15;;
4000000000000696:       00 78 38 60 23 00                   st4.rel [r14]=r15
40000000000006ac:       08 00 84 00                         br.ret.sptk.many b0;;

that can be slightly more efficient.

Another remark:
We are adding more variants of existing funtions, e.g.:

clear_bit()
__clear_bit()

I've got problems with hidden semantics.
Just reading the source (where they are used), I simply cannot guess
if a primitive is atomic or not, if it is with some fencing or w/o.

Cannot we have some "speaking names"? E.g.: bit_unlock_Natomic_rel()

Zoltan Menyhart
