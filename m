From: Jason Baron <jbaron@redhat.com>
Date: Tue, 28 Oct 2003 16:45:25 +0000
Subject: Re:  show_mem panics in 2.4.22
Message-Id: <marc-linux-ia64-106735996431447@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106731898417513@msgid-missing>
In-Reply-To: <marc-linux-ia64-106731898417513@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Tue, 28 Oct 2003, John Marvin wrote:

> > I'm running linux-2.4.22-ia64-030909 on an rx2600.  The show_mem()
> > function always causes a kernel panic.  This is reached when you send
> > 'SysRq m' or serial 'BREAK m' to find out about used memory, etc.
> >
> > The problem seems to be that this function is written assuming that
> > the discontiguous memory scheme is used, but that's not the case in my
> > configuration.  I see that in 2.6.0-test8 there are two versions of
> > the function for the contig/discontig cases.  The crash is on the line
> > that reads through pgdat->node_mem_map.  I'm not sure exactly what is
> > wrong with that.
> 
> 
> I'm not sure why this just started to show up. The problem is that
> the size of struct page doesn't divide into the page size evenly, so
> the structure overlaps holes in the mem_map array. Here is a fix,
> but I am still not sure of the performance implications (extra memory
> dereference). There may be a better fix, although not as simple, if
> this has performance implications.
> 
> The same bug probably exists in 2.6.
> 
> John Marvin
> jsm@fc.hp.com
> 
> 
> --- a/arch/ia64/mm/init.c	Tue Oct 28 01:25:54 2003
> +++ b/arch/ia64/mm/init.c	Tue Oct 28 01:31:26 2003
> @@ -485,7 +485,8 @@ ia64_page_valid (struct page *page)
>  {
>  	char byte;
>  
> -	return __get_user(byte, (char *) page) = 0;
> +	return     (__get_user(byte, (char *) page) = 0)
> +		&& (__get_user(byte, (char *) (page + 1) - 1) = 0);
>  }
>  
>  #define GRANULEROUNDDOWN(n) ((n) & ~(IA64_GRANULE_SIZE-1))
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

The count in show_mem() is not quite accurate, since we might count page
structures that are mapped to valid memory, but are zero filled and do not
correspond to valid memory. show_mem() will no longer oops, though. Since
ia64_page_valid, could be on several hot paths, we might just want to
restrict this check to the show_mem() function. This could have just
cropped up, if struct page had changed in size.

-Jason


