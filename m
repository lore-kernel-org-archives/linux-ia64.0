From: "Menyhart, Zoltan" <Zoltan.Menyhart@free.fr>
Date: Thu, 02 Jun 2005 22:55:42 +0000
Subject: Re: flush_icache_range
Message-Id: <429F8E6E.1090805@free.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

>  Zoltan> unique_caches - cache_levels = 2
>
>  Zoltan> I could not find anything making sure that we've got in this
>  Zoltan> case L1I and L2I, and not L1I and L3I (feeding through the
>  Zoltan> unified L2). Yes, I know there is no such a CPU (at the
>  Zoltan> moment) but the PAL spec. does not exclude it :-)
>
>I don't think it matters whether you pick up the stride from an
>i-cache or a unified cache.  As long as you take the minimum stride,
>it will work correctly.
>  
>
I mean:
- if the cache of a given level is split, then we need to take the stride
   size of the i-cache:
   pal_cache_config_info(level, /* cache_type = */ 1,...)
- if the cache of a given level is unified, then we need to take the stride
   size of the unified/data cache:
   pal_cache_config_info(level, /* cache_type = */ 2,...)
In my example I know only that some (but not all) the levels are split.
Guessing the existence of a split cache by not obtaining an "Invalid
argument" error form "pal_cache_config_info()" is a bit weak method...

Thanks,

Zoltan


