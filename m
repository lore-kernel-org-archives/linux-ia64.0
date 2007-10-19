From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 19 Oct 2007 14:15:10 +0000
Subject: Re: [IA64] Reduce __clear_bit_unlock overhead
Message-Id: <4718BBEE.9000808@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0710182037220.25820@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710182037220.25820@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> On Fri, 19 Oct 2007, Zoltan Menyhart wrote:
> 
> 
>>You may want to avoid assembly magics:
>>
>>static __inline__ void
>>__clear_bit_unlock(int const nr, volatile void * const addr)
>>{
>>       volatile __u32 * const m = (volatile __u32 *) addr + (nr >> 5);
>>
>>       *m &= ~(1 << (nr & 0x1f));
>>}
>>
>>GCC compiles volatile loads with ".acq" and stores with ".rel".
> 
> 
> But gcc does not generate the .nta type of store.

Can you please tell me what is the advantage of ".nta " on the store?
I far as I can see in the I2 Microarch. Guide, Table 3-2 Processor
Cache Hints, ".nta " on stores means:
- L2 NRU bit is not updated
- No slot is allocated in L3

In order to be able to take advantage of an "st.nta", you have to
use "ld.nta" in __clear_bit_unlock(), and at the bit lock
acquisition, too.

I assume the critical region data protected by the lock is in the
same cache line as the bit lock itself, therefore all loads /
stores have to use ".nta " - that the GCC wont generate.
Should you do it by hand, you would not use the cache as it is
assumed to be used, therefore the cache itself becomes less
efficient.

Nick Piggin wrote:
> Actually I personally would prefer to use a non-volatile pointer,
> and do the assembly explicitly. However, that's not for me to
> decide. Importantly, the load with acquire is not required and I
> agree it should go. Thanks for noticing that.

Well, one of the primary requirements is to avoid people
misunderstanding the code. I can accept that using explicit,
special assembly instructions can help people to understand
the code.

Zoltan
