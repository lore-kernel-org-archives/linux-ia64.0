From: Zoltan Menyhart <Zoltan.Menyhart@free.fr>
Date: Tue, 28 Mar 2006 21:42:20 +0000
Subject: Re: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <4429ADBC.50507@free.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603281853.k2SIrGg28290@unix-os.sc.intel.com>
In-Reply-To: <200603281853.k2SIrGg28290@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:
> Nick Piggin wrote on Tuesday, March 28, 2006 12:11 AM
> 
>>Also, I think there is still the issue of ia64 not having the
>>correct memory consistency semantics. To start with, all the bitops
>>and atomic ops which both modify their operand and return a value
>>should be full memory barriers before and after the operation,
>>according to Documentation/atomic_ops.txt.
>
> I suppose the usage of atomic ops is abused, it is used in both lock
> and unlock path.  And it naturally suck because it now requires full
> memory barrier.  A better way is to define 3 variants: one for lock
> path, one for unlock path, and one with full memory fence.

I agree. As I wrote a few days ago:

Why not to use separate bit operations for different purposes?

- e.g. "test_and_set_bit_N_acquire()" for lock acquisition
- "test_and_set_bit()", "clear_bit()" as they are today
- "release_N_clear_bit()"...

Thanks,

Zoltan

