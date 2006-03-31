From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 03:01:58 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603301855500.3045@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603310244.k2V2iQg28203@unix-os.sc.intel.com>
In-Reply-To: <200603310244.k2V2iQg28203@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 30 Mar 2006, Chen, Kenneth W wrote:

> Christoph Lameter wrote on Thursday, March 30, 2006 6:38 PM
> > > > Neither one is correct because there will always be one combination of 
> > > > clear_bit with these macros that does not generate the required memory 
> > > > barrier.
> > > 
> > > Can you give an example?  Which combination?
> > 
> > For Option(1)
> > 
> > smp_mb__before_clear_bit()
> > clear_bit(...)(
> 
> Sorry, you totally lost me.  It could me I'm extremely slow today.  For
> option (1), on ia64, clear_bit has release semantic already.  The comb
> of __before_clear_bit + clear_bit provides the required ordering.  Did
> I miss something?  By the way, we are talking about detail implementation
> on one specific architecture.  Not some generic concept that clear_bit
> has no ordering stuff in there.

We are talking about IA64 and IA64 only generates an single instruction 
with either release or acquire semantics for the case in which either 
smb_mb__before/after_clear_bit does nothing.

Neither acquire nor release is a memory barrier on IA64.

The combination of both does the equivalent but then we do not have both 
acquire and release if either smb_mb__before/after_clear bit does 
nothing.

For clear_bit you have both uses in the kernel

smb_mb_before_clear_bit()
clear_bit()

and

clear_bit()
smb_mb_after_clear_bit()


clear_bit() in itself does not have barrier semantics on IA64. Therefore 
smb_mb_after and before must both provide a memory barrier.


