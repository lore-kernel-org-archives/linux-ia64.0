From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sat, 01 Apr 2006 02:56:55 +0000
Subject: Re: Synchronizing Bit operations V2
Message-Id: <442DEBF7.1090806@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603301300430.1014@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com> <442C7B51.1060203@yahoo.com.au> <Pine.LNX.4.64.0603301921550.3145@schroedinger.engr.sgi.com> <442CAC11.4070803@yahoo.com.au> <Pine.LNX.4.64.0603310939570.6628@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603310939570.6628@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@SGI.com>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> On Fri, 31 Mar 2006, Nick Piggin wrote:

>>You acknowledge that you have to fix ia64 to match current semantics
>>first, right?
> 
> 
> Right. I believe I have done so by making both smb_mb_* full barriers.

All bitop and atomic test_and_set, inc_return, etc etc (ie. everything
that modifies the operand and returns something) needs to be a full
barrier before and after too.

>>Now people seem to be worried about the performance impact that will
>>have, so I simply suggest that adding two or three new macros for the
>>important cases to give you a 90% solution.
> 
> 
> We could transition some key locations of core code to use _mode bitops
> if there are performance problems.
> 
> 
>>I think Documentation/atomic_ops.txt isn't bad. smp_mb__* really
>>is a smp_mb, which can be optimised sometimes.
> 
> 
> Ok. Then we are on the same page and the solution I presented may be 
> acceptable. I have a new rev here that changes the naming a bit but I 
> think we are okay right?

Not sure, to be honest. I think it is probably something which needs
input from all the other arch people, and Linus, if you intend to use
it to introduce new types of barriers.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
