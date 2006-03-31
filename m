From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 01:09:28 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603301707300.2553@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603310059.k2V0x7g26953@unix-os.sc.intel.com>
In-Reply-To: <200603310059.k2V0x7g26953@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 30 Mar 2006, Chen, Kenneth W wrote:

> > > I know, I'm saying since it doesn't make any difference from API point of
> > > view whether it is acq, rel, or no ordering, then just make them rel as a
> > > "preferred" Operation on ia64.
> > 
> > That would make the behavior of clear_bit different from other bitops and 
> > references to volatile pointers. I'd like to have this as consistent as 
> > possible.
> 
> Yeah, but we just agreed that caller shouldn't be thinking clear_bit has
> memory ordering at all.

In general yes the caller should not be thinking about clear_bit having 
any memory ordering at all. However for IA64 arch specific code the bit 
operations must have a certain ordering semantic and it would be best that 
these are also consistent. clear_bit is not a lock operation and may 
f.e. be used for locking something.
