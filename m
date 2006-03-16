From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 16 Mar 2006 15:56:06 +0000
Subject: Re: [PATCH] Fix percpu interrupt allocation in mmtimer code
Message-Id: <20060316155606.GA6407@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060315143906.GE29195@sgi.com>
In-Reply-To: <20060315143906.GE29195@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 15, 2006 at 08:39:06AM -0600, Dimitri Sivanich wrote:
> The timer interrupt in the mmtimer code needs to be allocated as
> a percpu interrupt for acceptable performance on larger systems.
> 
> The code needs to be updated to set this up properly, as the
> SA_PERCPU_IRQ flag to request_interrupt is not supported.

Rather than letting the driver poke into irq code internals I'd suggest
you fux the request_irq code to properly support SA_PERCPU_IRQ.

