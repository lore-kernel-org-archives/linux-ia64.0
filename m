From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 17:43:00 +0000
Subject: Re: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603310939570.6628@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603301300430.1014@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
 <442C7B51.1060203@yahoo.com.au> <Pine.LNX.4.64.0603301921550.3145@schroedinger.engr.sgi.com>
 <442CAC11.4070803@yahoo.com.au>
In-Reply-To: <442CAC11.4070803@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, 31 Mar 2006, Nick Piggin wrote:

> > 
> > Right. From the earlier conversation I had the impression that this is what
> > you wanted.
> Perhaps it is the best way to go, but you need to fix ia64's
> current problems first. Again -- you don't plan to audit and
> convert _all_ current users in one go do you?

No. If you look at the patch you will see that this fixes the ia64 
problems for the existing scheme and then allows the use of new _mode 
bitops if you include bitops_mode.h from core code. This is designed for a 
gradual change.

> You acknowledge that you have to fix ia64 to match current semantics
> first, right?

Right. I believe I have done so by making both smb_mb_* full barriers.

> Now people seem to be worried about the performance impact that will
> have, so I simply suggest that adding two or three new macros for the
> important cases to give you a 90% solution.

We could transition some key locations of core code to use _mode bitops
if there are performance problems.

> I think Documentation/atomic_ops.txt isn't bad. smp_mb__* really
> is a smp_mb, which can be optimised sometimes.

Ok. Then we are on the same page and the solution I presented may be 
acceptable. I have a new rev here that changes the naming a bit but I 
think we are okay right?

