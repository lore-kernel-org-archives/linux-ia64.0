From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 30 Mar 2006 18:17:38 +0000
Subject: RE: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <Pine.LNX.4.64.0603301016330.32317@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <65953E8166311641A685BDF71D865826A23E13@cacexc12.americas.cpqcorp.net>
In-Reply-To: <65953E8166311641A685BDF71D865826A23E13@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Boehm, Hans" <hans.boehm@hp.com>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, Nick Piggin <nickpiggin@yahoo.com.au>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 30 Mar 2006, Boehm, Hans wrote:

> > The compiler will select that at compile time. One has the 
> > option of also generating run time seletion by specifying a 
> > variable instead of a constant when callig these functions.
> I would view the latter as a disadvantage, since I can't think of a case
> in which you wouldn't want it reported as an error instead, at least if
> you care about performance.  If you know of one, I'd be very interested.

In that case: We could check that a constant is passed at compile time.
 
> The first form does have the advantage that it's possible to build up
> more complicated primitives from simpler ones without repeating the
> definition four times.

What is the first form? The advantage of passing a parameter is more 
compact code and less definitions.

