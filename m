From: Dean Nelson <dcn@sgi.com>
Date: Wed, 07 Jul 2004 19:40:17 +0000
Subject: Re: [PATCH 3/4] SGI Altix cross partition functionality
Message-Id: <20040707194017.GA31289@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040617183638.GA3712@sgi.com>
In-Reply-To: <20040617183638.GA3712@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 17, 2004 at 08:22:29PM +0100, Christoph Hellwig wrote:
> +	/*
> +	 * Zero out MOST of the entry for this partition. Only the fields
> +	 * following `references' will be zeroed. The others must remain
> +	 * `viable' across partition ups and downs, since they may be
> +	 * referenced during this memset() operation.
> +	 */
> +	memset((u8 *)&part->references + sizeof(part->references), 0,
> 
> cast to u8 * in memset? Ummm..

I'm not exactly sure what you're objecting to here. The cast is necessary for
a correct result. The following two lines do not give the same result (the
'references' field is an atomic_t):
 
        (u8 *)&part->references + sizeof(part->references)
        &part->references + sizeof(part->references)
 
So is it the use of 'u8' instead of 'unsigned char' or 'char' that you object
to? Or is it the complexity of the args to memset? The entire memset call was
originally as follows:
 
        memset((u8 *)&part->references + sizeof(part->references), 0,
                (u64)(part + 1) - (u64)((u8 *)&part->references +
                                                sizeof(part->references)));
 
Would you prefer it to be something like?
 
        u8 *addr;
        size_t nbytes;
 
 
        addr = (u8 *) &part->references + sizeof(part->references);
        nbytes = (size_t) (part + 1) - (size_t) addr;
        memset(addr, 0, nbytes);
 
Or is it something else that you object to?
 
Thanks,
Dean

