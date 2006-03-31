From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 31 Mar 2006 04:12:01 +0000
Subject: Re: Synchronizing Bit operations V2
Message-Id: <442CAC11.4070803@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603301300430.1014@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com> <442C7B51.1060203@yahoo.com.au> <Pine.LNX.4.64.0603301921550.3145@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301921550.3145@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> On Fri, 31 Mar 2006, Nick Piggin wrote:
> 
> 
>>This has acquire and release, instead of the generic kernel
>>memory barriers rmb and wmb. As such, I don't think it would
>>get merged.
> 
> 
> Right. From the earlier conversation I had the impression that this is 
> what you wanted.
>  

Perhaps it is the best way to go, but you need to fix ia64's
current problems first. Again -- you don't plan to audit and
convert _all_ current users in one go do you?

> 
>>>Note that the current semantics for bitops IA64 are broken. Both
>>>smp_mb__after/before_clear_bit are now set to full memory barriers
>>>to compensate which may affect performance.
>>
>>I think you should fight the fights you can win and get a 90%
>>solution ;) at any rate you do need to fix the existing routines
>>unless you plan to audit all callers...
>>
>>First, fix up ia64 in 2.6-head, this means fixing test_and_set_bit
>>and friends, smp_mb__*_clear_bit, and all the atomic operations that
>>both modify and return a value.
>>
>>Then add test_and_set_bit_lock / clear_bit_unlock, and apply them
>>to a couple of critical places like page lock and buffer lock.
>>
>>Is this being planned?
> 
> 
> That sounds like a long and tedious route to draw out the pain for a 
> couple of years and add loads of additional macro definitions all over the 
> header files. I'd really like a solution that allows a gradual 
> simplification of the macros and that has clear semantics.
> 

Why? Yours is the long drawn out plan.

You acknowledge that you have to fix ia64 to match current semantics
first, right?

Now people seem to be worried about the performance impact that will
have, so I simply suggest that adding two or three new macros for the
important cases to give you a 90% solution.

You would then be free to discuss and design a 95% solution ;)

> So far it seems that I have not even been able to find the definitions for 
> the proper behavior of memory barriers.

I think Documentation/atomic_ops.txt isn't bad. smp_mb__* really
is a smp_mb, which can be optimised sometimes.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
