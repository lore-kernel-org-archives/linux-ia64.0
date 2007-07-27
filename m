From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 27 Jul 2007 22:06:09 +0000
Subject: Re: [PATCH] flush cache fixes for ia64 [1/2] migration fix
Message-Id: <20070728070609.3a775842.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070727133657.8c9c6803.kamezawa.hiroyu@jp.fujitsu.com>
	<20070727133843.6cd3f57a.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0707270934300.15619@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0707270934300.15619@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, nickpiggin@yahoo.com.au, Zoltan.Menyhart@bull.net

On Fri, 27 Jul 2007 09:39:16 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> This will have no effect on x86_64, ia64 and i386. Maybe useful for 
> virtually mapped platforms (parisc)?
> 
yes.

- Kame

> asm-ia64/cacheflush.c
> 
> #define flush_icache_page(vma,page)             do { } while (0)
> 
> Acked-by: Christoph Lameter <clameter@sgi.com>
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
