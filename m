From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 30 Mar 2006 01:34:02 +0000
Subject: Re: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <442B358A.4060805@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603290645.k2T6jbg03728@unix-os.sc.intel.com>
In-Reply-To: <200603290645.k2T6jbg03728@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Christoph Lameter <clameter@sgi.com>, Zoltan Menyhart <Zoltan.Menyhart@free.fr>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:

>Nick Piggin wrote on Tuesday, March 28, 2006 6:36 PM
>
>>Hmm, not sure. Maybe a few new bitops with _lock / _unlock postfixes?
>>For page lock and buffer lock we'd just need test_and_set_bit_lock,
>>clear_bit_unlock, smp_mb__after_clear_bit_unlock.
>>
>>I don't know, _for_lock might be a better name. But it's getting long.
>>
>
>I think kernel needs all 4 variants:
>
>clear_bit
>clear_bit_lock
>clear_bit_unlock
>clear_bit_fence
>
>And the variant need to permutated on all other bit ops ...  I think it
>would be indeed a better API and be more explicit about the ordering.
>
>

We could just introduce them as required, though? clear_bit_fence shouldn't
be required for ia64 any longer, if you change bitops to be full barriers,
right?

And for now, let's just not let people open critical sections unless doing
a test_and_set, nor close them unless doing a plain clear?

It seems that memory ordering model seems to be almost too much for people
to cope with already, so would it be reasonable to require some performance
justification before adding more?

--

Send instant messages to your online friends http://au.messenger.yahoo.com 
