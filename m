From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 02:51:25 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603310250.k2V2ofg28252@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Christoph Lameter' <clameter@sgi.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Zoltan Menyhart' <Zoltan.Menyhart@bull.net>, "'Boehm, Hans'" <hans.boehm@hp.com>, "'Grundler, Grant G'" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Chen, Kenneth W wrote on Thursday, March 30, 2006 6:45 PM
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

By the way, this is the same thing on x86: look at include/asm-i386/bitops.h:

#define smp_mb__before_clear_bit()      barrier()
#define smp_mb__after_clear_bit()       barrier()

A simple compiler barrier, nothing but
#define barrier() __asm__ __volatile__("": : :"memory")

See, no memory ordering there, because clear_bit already has a LOCK prefix.

- Ken
