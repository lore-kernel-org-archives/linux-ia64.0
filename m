From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 03:08:44 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603301907070.3145@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603310301.k2V31Gg28423@unix-os.sc.intel.com>
In-Reply-To: <200603310301.k2V31Gg28423@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Zoltan Menyhart' <Zoltan.Menyhart@bull.net>, "'Boehm, Hans'" <hans.boehm@hp.com>, "'Grundler, Grant G'" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 30 Mar 2006, Chen, Kenneth W wrote:

> > > See, no memory ordering there, because clear_bit already has a LOCK prefix.
> No, not the memory ordering semantics you are thinking about.  It just tell
> compiler not to be over smart and schedule a load operation above that point
> Intel compiler is good at schedule memory load way ahead of its use to hide
> memory latency. gcc probably does that too, I'm not 100% sure. This prevents
> the compiler to schedule load before that line.

The compiler? I thought we were talking about the processor.

I was referring to the LOCK prefix. Doesnt that insure the processor to 
go into a special state and make the bus go into a special state that 
implies a barrier?

