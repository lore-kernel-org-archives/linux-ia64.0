From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 00:58:25 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603301657470.2068@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F061AAF44@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F061AAF44@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: David Mosberger-Tang <David.Mosberger@acm.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 30 Mar 2006, Luck, Tony wrote:

> > Also some higher level functions may want to have the mode passed to them 
> > as parameters. See f.e. include/linux/buffer_head.h. Without the 
> > parameters you will have to maintain farms of definitions for all cases.
> 
> But if any part of the call chain from those higher level functions
> down to these low level functions is not inline, then the compiler
> won't be able to collapse out the "switch (mode)" ... so we'd end up
> with a ton of extra object code.

Correct. But such bitops are typically defined to be inline.
