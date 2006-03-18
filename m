From: Andrew Morton <akpm@osdl.org>
Date: Sat, 18 Mar 2006 09:49:00 +0000
Subject: Re: [PATCH] Add SA_PERCPU_IRQ flag support
Message-Id: <20060318014900.65889f69.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317003114.GA1735@sgi.com>
	<20060317152645.52112021.akpm@osdl.org>
In-Reply-To: <20060317152645.52112021.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: sivanich@sgi.com, torvalds@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hch@infradead.org, clameter@sgi.com, jes@sgi.com

Andrew Morton <akpm@osdl.org> wrote:
>
> +#ifdef ARCH_HAS_IRQ_PER_CPU
>  +	if (new->flags & SA_PERCPU_IRQ)
>  +		desc->status |= IRQ_PER_CPU;
>  +#endif

OK, five architectures define ARCH_HAS_IRQ_PER_CPU but only one of them
defines SA_PERCPU_IRQ.    Giving up.
