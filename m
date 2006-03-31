From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 00:51:21 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603301650220.2068@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603310049.k2V0nVg26779@unix-os.sc.intel.com>
In-Reply-To: <200603310049.k2V0nVg26779@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 30 Mar 2006, Chen, Kenneth W wrote:

> > It precise the uncleanness in ia64 that such semantics are attached to 
> > these bit operations which may lead people to depend on those. We need to 
> > either make these explicit or not depend on them.
> 
> I know, I'm saying since it doesn't make any difference from API point of
> view whether it is acq, rel, or no ordering, then just make them rel as a
> "preferred" Operation on ia64.

That would make the behavior of clear_bit different from other bitops and 
references to volatile pointers. I'd like to have this as consistent as 
possible.

