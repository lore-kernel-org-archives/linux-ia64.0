From: dann frazier <dannf@hp.com>
Date: Mon, 28 Nov 2005 15:57:02 +0000
Subject: Re: initrd_size inflation breaks initramfs
Message-Id: <1133193422.6062.109.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <1133159027.6062.98.camel@localhost>
In-Reply-To: <1133159027.6062.98.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2005-11-28 at 10:44 +0100, Andreas Schwab wrote:
> dann frazier <dannf@hp.com> writes:
> 
> > My guess is that this is a bug in elilo.
> 
> Try this patch:
> 
> --- initrd.c
> +++ initrd.c
> @@ -94,6 +94,9 @@
>  
>  	initrd->start_addr = start_addr;
>  
> +	/* Clear extra memory since we don't pass the exact size.  */
> +	Memset(start_addr + size, 0, (pgcnt << EFI_PAGE_SHIFT) - size);
> +
>  	return ELILO_LOAD_SUCCESS;
>  
>  error:
> 

Thanks Andreas, that works.  Though I wonder if it wouldn't be better to
keep track of the actual initrd size?

-- 
dann frazier <dannf@hp.com>

