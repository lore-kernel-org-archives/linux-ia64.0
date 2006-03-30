From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 30 Mar 2006 01:57:59 +0000
Subject: Re: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <442B3B27.3030802@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com> <442AA13B.3050104@bull.net>
In-Reply-To: <442AA13B.3050104@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, Zoltan.Menyhart@free.fr, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, William Lee Irwin III <wli@holomorphy.com>

Zoltan Menyhart wrote:

> Christoph Lameter wrote:
>
>> [...]
>>  void fastcall unlock_buffer(struct buffer_head *bh)
>>  {
>> +    smp_mb__before_clear_bit();
>>      clear_buffer_locked(bh);
>> -    smp_mb__after_clear_bit();
>>      wake_up_bit(&bh->b_state, BH_Lock);
>>  }
>
>
> The sequence:
>
>     smp_mb__before_clear_bit();
>     clear_buffer_locked(bh);
>
> is correct (yet not efficient for all architectures).
>

Yes, this is explicitly documented in the wake_up_bit interface. I
don't really think it needs to be changed, does it? Bill did most
of this work I think, so I've cc'ed him.

> We have got here two unrelated operations: ending a critical section
> and waking up the eventual waiters. What we need is a barrier between
> these two unrelated operations.
> It is not "smp_mb__after_clear_bit()" but a simple "smp_mb()".
> The correct code is:
>
> void fastcall unlock_buffer(struct buffer_head *bh)
> {
>   smp_mb__before_clear_bit();
>   clear_buffer_locked(bh);
>   smp_mb();
>   wake_up_bit(&bh->b_state, BH_Lock);
> }
>

If you were going to do that, I'd prefer my suggestion.

clear_buffer_locked(); /* clear_bit_unlock */
smp_mb__after_clear_bit_unlock();
wake_up_bit()

Nick

--

Send instant messages to your online friends http://au.messenger.yahoo.com 
