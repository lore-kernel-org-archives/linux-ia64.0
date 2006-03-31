From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 31 Mar 2006 00:56:25 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F061AAF44@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>, David Mosberger-Tang <David.Mosberger@acm.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

> Also some higher level functions may want to have the mode passed to them 
> as parameters. See f.e. include/linux/buffer_head.h. Without the 
> parameters you will have to maintain farms of definitions for all cases.

But if any part of the call chain from those higher level functions
down to these low level functions is not inline, then the compiler
won't be able to collapse out the "switch (mode)" ... so we'd end up
with a ton of extra object code.

-Tony
