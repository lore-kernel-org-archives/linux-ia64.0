From: "Boehm, Hans" <hans.boehm@hp.com>
Date: Wed, 29 Mar 2006 22:56:36 +0000
Subject: RE: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <65953E8166311641A685BDF71D865826A23D40@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@free.fr>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

The slides and paper are really discussing a different issue, namely the
extent to which it is safe to use a compiler like gcc which was
primarily designed for sequential code on concurrent code, using a model
similar to what pthreads (or I believe the kernel) uses.  The short
answer is that it isn't.  There is some low probablity that the compiler
will introduce a data race.  And that is very hard to anticipate based
on the source, and seems to be similarly hard to avoid by any known
programming guidelines.  The solution strategy is to fix language
standards and compilers.  We're working on the first part for now.

You can find the paper corresponding to those slides at
http://portal.acm.org/citation.cfm?doid65010.1065042 or
http://www.hpl.hp.com/techreports/2004/HPL-2004-209.html .

Returning to the original topic, I don't think I'm the one to design the
bitops API, since I'm not sufficiently familiar with the kernel issues.
I did design a vaguely comparable user-level interface that addresses
atomic operations in general, not specifically bit vector operations.
That's described at http://www.hpl.hp.com/research/linux/atomic_ops/, or
more specifically at
http://www.hpl.hp.com/research/linux/atomic_ops/README.txt .  I'm making
another pass over the C++ proposal version as we speak, but it's mostly
similar in spirit.  Design decisions that have turned out to be dubious
are:

1. Including all ordering types for simple load and store operations.
Some don't make sense.

2. The set of ordering constraints there is probably too large.  None,
acquire, release, and full really seem to be the important ones.
dd_acquire_read is nice, but probably nonsensical.  Hardware tends to
give you data dependent ordering for free, but the compiler doesn't
preserve it.

Hans

> -----Original Message-----
> From: Christoph Lameter 
> [mailto:christoph@schroedinger.engr.sgi.com] On Behalf Of 
> Christoph Lameter
> Sent: Wednesday, March 29, 2006 2:18 PM
> To: Boehm, Hans
> Cc: Grundler, Grant G; Chen, Kenneth W; Nick Piggin; Zoltan 
> Menyhart; akpm@osdl.org; linux-kernel@vger.kernel.org; 
> linux-ia64@vger.kernel.org
> Subject: RE: Fix unlock_buffer() to work the same way as bit_unlock()
> 
> On Wed, 29 Mar 2006, Boehm, Hans wrote:
> 
> > Somewhat improved slides for the talk Grant is referring to are at 
> > 
> http://www.hpl.hp.com/personal/Hans_Boehm/misc_slides/pldi05_threads.p
> > df
> 
> Hmm.. A paper on that subject would be better. Cannot get 
> much from the slides.
> 
> > It's hard to get this stuff right.  But we knew that.
> 
> Could you come up with a proposal how to correctly define and 
> API to bit ops in such a way that they work for all 
> architectures and allow us to utilize all the features that 
> processors may have?
> 
