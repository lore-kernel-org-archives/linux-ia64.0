From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 03:14:51 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603310314.k2V3E6g28521@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0603301909590.3145@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Lameter' <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, March 30, 2006 7:12 PM
> > The use of
> >         smp_mb__before_clear_bit();
> >         clear_bit( ... );
> > 
> > is: all memory operations before this call will be visible before
> > the clear_bit().  To me, that's release semantics.
> 
> What of it? Release semantics are not a full fence or memory barrier.

The API did not require a full fence.  It is defined as a one way fence.
