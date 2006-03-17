From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 17 Mar 2006 02:09:42 +0000
Subject: Re: [PATCH] Add SA_PERCPU_IRQ flag support
Message-Id: <20060317020942.GA20227@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317003114.GA1735@sgi.com>
In-Reply-To: <20060317003114.GA1735@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <clameter@sgi.com>, Jes Sorensen <jes@sgi.com>

On Thu, Mar 16, 2006 at 06:31:14PM -0600, Dimitri Sivanich wrote:
> The generic request_irq/setup_irq code should support the SA_PERCPU_IRQ flag.
> 
> Not sure why it was left out, but this patch adds that support.
> 
> Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>
> 
> Index: linux/kernel/irq/manage.c
> =================================> --- linux.orig/kernel/irq/manage.c	2006-03-16 14:05:27.957927445 -0600
> +++ linux/kernel/irq/manage.c	2006-03-16 14:06:02.283661867 -0600
> @@ -201,6 +201,9 @@ int setup_irq(unsigned int irq, struct i
>  	 * The following block of code has to be executed atomically
>  	 */
>  	spin_lock_irqsave(&desc->lock,flags);
> +	if (new->flags & SA_PERCPU_IRQ) {
> +		desc->status |= IRQ_PER_CPU;
> +	}

looks good, although the braces aren't really needed for single-line
conditionals.

