From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 12 Aug 2004 09:20:09 +0000
Subject: Re: Altix I/O code reorganization - 14 of 21
Message-Id: <20040812102009.G5988@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408112333.i7BNXMXH163770@fsgi900.americas.sgi.com>
In-Reply-To: <200408112333.i7BNXMXH163770@fsgi900.americas.sgi.com>; from pfg@sgi.com on Wed, Aug 11, 2004 at 06:33:22PM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hch@infradead.org

On Wed, Aug 11, 2004 at 06:33:22PM -0500, Pat Gefre wrote:
> > 007-io-hub-provider:
> >    tio_provider and hub_provider have exactly the same methods, no need to
> >    keep the xtalk_provider_t abstraction at all
> > 
> 
> The abstraction was done for future expansion.  We have removed it 
> and in the future if we do need to abstract these 2 providers, we will 
> submit another patch.

> +xtalk_provider_t hub_provider = {
> +
> +	(xtalk_intr_alloc_f *) sal_xtalk_intr_alloc,
> +	(xtalk_intr_free_f *) sal_xtalk_intr_free,
> +
> +};
> +
> +xtalk_provider_t tio_provider = {
> +
> +	(xtalk_intr_alloc_f *) sal_xtalk_intr_alloc,
> +	(xtalk_intr_free_f *) sal_xtalk_intr_free,
> +
> +};

you still have it in this patch.

