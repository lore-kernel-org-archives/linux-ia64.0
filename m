From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 02:55:47 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603301855280.3045@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603310250.k2V2ofg28252@unix-os.sc.intel.com>
In-Reply-To: <200603310250.k2V2ofg28252@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Zoltan Menyhart' <Zoltan.Menyhart@bull.net>, "'Boehm, Hans'" <hans.boehm@hp.com>, "'Grundler, Grant G'" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 30 Mar 2006, Chen, Kenneth W wrote:

> By the way, this is the same thing on x86: look at include/asm-i386/bitops.h:
> 
> #define smp_mb__before_clear_bit()      barrier()
> #define smp_mb__after_clear_bit()       barrier()
> 
> A simple compiler barrier, nothing but
> #define barrier() __asm__ __volatile__("": : :"memory")
> 
> See, no memory ordering there, because clear_bit already has a LOCK prefix.

And that implies barrier behavior right?

