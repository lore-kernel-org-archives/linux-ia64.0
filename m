From: "Boehm, Hans" <hans.boehm@hp.com>
Date: Thu, 30 Mar 2006 17:57:40 +0000
Subject: RE: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <65953E8166311641A685BDF71D865826A23E13@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

> From: Christoph Lameter 
> 
> On Thu, 30 Mar 2006, Zoltan Menyhart wrote:
> 
> > Form semantical point of view, the forms:
> > 
> > 	bit_foo(..., mode)
> > and
> > 	bit_foo_mode(...)
> > 
> > are equivalent.
> 
> Correct but the above form leads to less macro definitions.
>  
> > However, I do not think your implementation would be 
> efficient due to 
> > selecting the ordering mode at run time:
> 
> The compiler will select that at compile time. One has the 
> option of also generating run time seletion by specifying a 
> variable instead of a constant when callig these functions.
I would view the latter as a disadvantage, since I can't think of a case
in which you wouldn't want it reported as an error instead, at least if
you care about performance.  If you know of one, I'd be very interested.

The first form does have the advantage that it's possible to build up
more complicated primitives from simpler ones without repeating the
definition four times.

I'm not sure there's a clear winner here.

In the C++ case, I currently expect we will go with template arguments,
which are guaranteed to be static, but are an option you don't have ...

Hans
