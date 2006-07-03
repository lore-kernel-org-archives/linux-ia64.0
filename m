From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 03 Jul 2006 11:56:32 +0000
Subject: Re: [RFC][patch 09/44] IA64: Use the new IRQF_ constansts
Message-Id: <1151927792.24611.45.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060701145211.856500000@cruncher.tec.linutronix.de>
	 <20060701145224.258259000@cruncher.tec.linutronix.de>
	 <yq0r712hqd1.fsf@jaguar.mkp.net>
In-Reply-To: <yq0r712hqd1.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org, torvalds@osdl.org

On Mon, 2006-07-03 at 07:36 -0400, Jes Sorensen wrote:
> >>>>> "Thomas" = Thomas Gleixner <tglx@linutronix.de> writes:
> 
> Thomas> Use the new IRQF_ constants and remove the SA_INTERRUPT define
> 
> Hi Thomas,
> 
> You forgot to remove the duplicate define of IRQF_PERCPU from
> include/asm-ia64/irq.h when you introduced the one in
> include/linux/interrupt.h.
> 
> On ia64, without this patch, building Linus' git tree spits out
> compile warnings left right and center (harmless ones though).
> 
> I checked the ia64 code and I don't see any place that actually relied
> on the old define or hardcoded it in asm, but I could be wrong of
> course.
> 
> It compiles, it boots, Enterprise Ready<tm>!

Andrew sent a fix to Linus already.
	
	tglx


