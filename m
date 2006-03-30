From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 30 Mar 2006 17:17:46 +0000
Subject: Re: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <Pine.LNX.4.64.0603300916180.31971@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <65953E8166311641A685BDF71D865826A23D40@cacexc12.americas.cpqcorp.net>
 <Pine.LNX.4.64.0603291529160.26011@schroedinger.engr.sgi.com>
 <442B9A2A.7000306@bull.net>
In-Reply-To: <442B9A2A.7000306@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 30 Mar 2006, Zoltan Menyhart wrote:

> Form semantical point of view, the forms:
> 
> 	bit_foo(..., mode)
> and
> 	bit_foo_mode(...)
> 
> are equivalent.

Correct but the above form leads to less macro definitions.
 
> However, I do not think your implementation would be efficient due to
> selecting the ordering mode at run time:

The compiler will select that at compile time. One has the option of also 
generating run time seletion by specifying a variable instead of a 
constant when callig these functions.

> In addition, we may want to inline these primitives...

Of course.
 
> A compile-time selection of the appropriate code sequence would help.

They are compile time selected.

