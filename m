From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 07 Feb 2005 02:58:32 +0000
Subject: Re: take5: vector sharing (Large I/O system support)
Message-Id: <4206D958.9070409@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4201FC3A.40803@jp.fujitsu.com>
In-Reply-To: <4201FC3A.40803@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

Thank you for your comments.

David Mosberger wrote:
> After a quick glance over the patch:
> 
>  - There are several lines introduced with trailing whitespace (some
>    of them long).  If you use emacs, you can get rid of them
>    with delete-trailing-whitespace.  Please do so.

Oh, sorry.
I'll fix this.

> 
>  - I'm not a fan of coding retry-loops with labels; I'd much rather
>    have them be do/while-loops.  In this particular case:
> 

Ok, I'll change the patch to use do/while-loops instead
of using goto.

> 
> How does the kernel fail when we're running out of statically
> allocated structures _before_ kmalloc() is initialized?  It better be
> an obvious failure so one goes "oh, I better increase
> NR_RTE_CACHE_ENTRIES" instead of having to debug a weird crash deep in
> the allocator.

The lack of statically allocated structures is very rare
case (I think this will happen only if system has many
platform interrupt sources), so I didn't add the check if
we're running out of these structures. But, it possibly
happens and it will be hard to know what is happening. So
I'll change my patch to display debug messages.

Thanks,
Kenji Kaneshige
