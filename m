From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 03:12:11 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603301909590.3145@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603310309.k2V39dg28480@unix-os.sc.intel.com>
In-Reply-To: <200603310309.k2V39dg28480@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 30 Mar 2006, Chen, Kenneth W wrote:

> Christoph Lameter wrote on Thursday, March 30, 2006 7:02 PM
> > We are talking about IA64 and IA64 only generates an single instruction 
> > with either release or acquire semantics for the case in which either 
> > smb_mb__before/after_clear_bit does nothing.
> > 
> > Neither acquire nor release is a memory barrier on IA64.
> 
> 
> The use of
>         smp_mb__before_clear_bit();
>         clear_bit( ... );
> 
> is: all memory operations before this call will be visible before
> the clear_bit().  To me, that's release semantics.

What of it? Release semantics are not a full fence or memory barrier.

> On ia64, we map the following:
> #define Smp_mb__before_clear_bit      do { } while (0)
> #define clear_bit                     clear_bit_mode(..., RELEASE)
> 
> Which looked perfect fine to me.  I don't understand why you say it does
> not provide memory ordering.

It does not provide a memory barrier / fence. Later memory references can 
still be moved by the processor above the instruction with release semantics.
