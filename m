From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 31 Mar 2006 00:44:01 +0000
Subject: Re: Synchronizing Bit operations V2
Message-Id: <442C7B51.1060203@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603301300430.1014@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> Changelog:
> 
> V2
> 	- Fix various oversights
> 	- Follow Hans Boehm's scheme for the barrier logic
> 
> The following patchset implements the ability to specify a
> synchronization mode for bit operations.
> 
> I.e. instead of set_bit(x,y) we can do set_bit(x,y, mode).
> 
> The following modes are supported:
> 

This has acquire and release, instead of the generic kernel
memory barriers rmb and wmb. As such, I don't think it would
get merged.

> Note that the current semantics for bitops IA64 are broken. Both
> smp_mb__after/before_clear_bit are now set to full memory barriers
> to compensate which may affect performance.

I think you should fight the fights you can win and get a 90%
solution ;) at any rate you do need to fix the existing routines
unless you plan to audit all callers...

First, fix up ia64 in 2.6-head, this means fixing test_and_set_bit
and friends, smp_mb__*_clear_bit, and all the atomic operations that
both modify and return a value.

Then add test_and_set_bit_lock / clear_bit_unlock, and apply them
to a couple of critical places like page lock and buffer lock.

Is this being planned?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
