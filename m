From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 19 Oct 2007 10:58:08 +0000
Subject: Re: [IA64] Reduce __clear_bit_unlock overhead
Message-Id: <Pine.LNX.4.64.0710190354510.28586@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0710182037220.25820@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710182037220.25820@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 19 Oct 2007, Zoltan Menyhart wrote:

> You may want to avoid assembly magics:
> 
> static __inline__ void
> __clear_bit_unlock(int const nr, volatile void * const addr)
> {
>        volatile __u32 * const m = (volatile __u32 *) addr + (nr >> 5);
> 
>        *m &= ~(1 << (nr & 0x1f));
> }
> 
> GCC compiles volatile loads with ".acq" and stores with ".rel".

But gcc does not generate the .nta type of store.

> Cannot we have some "speaking names"? E.g.: bit_unlock_Natomic_rel()

The convention is that __xxx is the non atomic variant.

