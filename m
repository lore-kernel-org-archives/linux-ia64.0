From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 23 Feb 2005 22:34:04 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <20050223223404.GA21383@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net> <20050222020309.4289504c.akpm@osdl.org> <yq0ekf8lksf.fsf@jaguar.mkp.net> <20050222175225.GK28741@parcelfarce.linux.theplanet.co.uk> <20050222112513.4162860d.akpm@osdl.org> <yq0zmxwgqxr.fsf@jaguar.mkp.net> <20050222153456.502c3907.akpm@osdl.org> <yq0sm3negtb.fsf@jaguar.mkp.net>
In-Reply-To: <yq0sm3negtb.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@wildopensource.com>
Cc: Andrew Morton <akpm@osdl.org>, matthew@wil.cx, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> +		page = pfn_to_page(p >> PAGE_SHIFT);
> +		/*
> +		 * On ia64 if a page has been mapped somewhere as
> +		 * uncached, then it must also be accessed uncached
> +		 * by the kernel or data corruption may occur
> +		 */
> +#ifdef ARCH_HAS_TRANSLATE_MEM_PTR
> +		ptr = arch_translate_mem_ptr(page, p);
> +#else
> +		ptr = __va(p);
> +#endif

Please remove the ifdef by letting every architecture implement a
arch_translate_mem_ptr (and give it a saner name while you're at it).

Also shouldn't the pfn_to_page be done inside arch_translate_mem_ptr?
The struct page * isn't used anywhere else.

> +	if (!range_is_allowed(p, p + count))

isn't the name a little too generic?

> +
> +	written = 0;
> +
> +#if defined(__sparc__) || (defined(__mc68000__) && defined(CONFIG_MMU))
> +	/* we don't have page 0 mapped on sparc and m68k.. */
> +	if (p < PAGE_SIZE) {
> +		unsigned long sz = PAGE_SIZE - p;
> +		if (sz > count)
> +			sz = count; 
> +		/* Hmm. Do something? */
> +		buf += sz;
> +		p += sz;
> +		count -= sz;
> +		written += sz;
> +	}
> +#endif

While you're at it replace the ifdef mania with a #ifdef
__HAVE_ARCH_PAGE_ZERO_MAPPED or something similar.

