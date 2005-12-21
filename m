From: Mark Maule <maule@sgi.com>
Date: Wed, 21 Dec 2005 19:18:43 +0000
Subject: Re: [PATCH 3/4] per-platform IA64_{FIRST,LAST}_DEVICE_VECTOR definitions
Message-Id: <20051221191843.GJ9920@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051221184337.5003.85653.32527@attica.americas.sgi.com> <20051221184353.5003.87888.74327@attica.americas.sgi.com> <20051221190916.GE2361@parisc-linux.org>
In-Reply-To: <20051221190916.GE2361@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Wed, Dec 21, 2005 at 12:09:16PM -0700, Matthew Wilcox wrote:
> On Wed, Dec 21, 2005 at 12:42:46PM -0600, Mark Maule wrote:
> >  #ifndef CONFIG_X86_IO_APIC
> >  int vector_irq[NR_VECTORS] = { [0 ... NR_VECTORS - 1] = -1};
> > -u8 irq_vector[NR_IRQ_VECTORS] = { FIRST_DEVICE_VECTOR , 0 };
> > +u8 irq_vector[NR_IRQ_VECTORS] = { [0 ... NR_IRQ_VECTORS - 1 ] = 0 };
> 
> Isn't this just a very complicated way of saying:
> 
> u8 irq_vector[NR_IRQ_VECTORS];
> 
> ?

Ok.  Was just following the lead of this:

static struct msi_desc* msi_desc[NR_IRQS] = { [0 ... NR_IRQS-1] = NULL };

So arrays are always init'd to zero?

Mark
