From: "Menyhart, Zoltan" <Zoltan.Menyhart@free.fr>
Date: Thu, 02 Jun 2005 21:37:36 +0000
Subject: Re: flush_icache_range
Message-Id: <429F7C20.1090508@free.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

>The changes to the assembly-file look mostly OK, except for the usual
>white-space issues (trailing whitespace, introduction of new, useless
>blank lines).
>  
>
Well, if I add just 1 or 2 lines, as I did in my first patch, I respect 
the original way of
whitespace usage.
I wanted to make it more easy to read, otherwise, some silly errors can 
slip in more easily.

>More importantly, it looks to me like there is an off-by-one bug:
>ar.lc needs to be initialized to loop_count-1.  Which raises the
>question: how well has this been tested?  Or am I missing something?
>  
>
It is calculated as:

loop_counter = ( end_address - start_address - 1 )  / stride_size

Most of the cases we flush entire pages.
In these cases, "loop_counter" seems to be correct.

Otherwise, if at least "start_address" is stride size aligned,
(ELF loader: text size is N * 16), we are still safe.

Otherwise, if only "end_address" is stride size aligned,
(not of very much interest), we are still safe.

Otherwise, if none of them is stride size aligned,
(e.g. a debugger may request to flush 2 bundles spanning over a
stride border), we will miss to flush the 2nd stride.

I propose to round down "start_address" to be stride size aligned.

>As for setup.c: I'd get rid of LOG_2_I_CACHE_STRIDE_SIZE and just
>initialize log_2_i_cache_stride_size to 5 (there is no point in
>initializing it with a random & useless value).
>  
>
"log_2_i_cache_stride_size" is not initialized to any stride size, it 
calculates the min. value.
Should "pal_cache_config_info" fail, you need something useful to be 
able to boot up.

I 'd rather keep "LOG_2_I_CACHE_STRIDE_SIZE", I like speaking names.
Perhaps "LOG_2_DEFAULT_I_CACHE_STRIDE_SIZE" would be even better :-)

>Also, I think you should do take the minimum of _all_ cache-levels,
>not just level 1 (yes, I also have a hard time imagining a system
>where the higher level has a smaller stride, but I don't think there
>is anything that prevents such a system).
>  
>
Well, things are getting complicated :-) I can add it...
I've got a concern about the "unique_caches" returned by 
"pal_cache_summary()".
Let's assume that

unique_caches - cache_levels = 2

I could not find anything making sure that we've got in this case L1I 
and L2I, and not
L1I and L3I (feeding through the unified L2). Yes, I know there is no 
such a CPU
(at the moment) but the PAL spec. does not exclude it :-)

Thanks,

Zoltan



