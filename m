From: Jack Steiner <steiner@sgi.com>
Date: Mon, 10 Dec 2001 22:57:33 +0000
Subject: Re: [Linux-ia64] pio barriers
Message-Id: <marc-linux-ia64-105590698805671@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805669@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805669@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> I noticed that in asm-ia64/system.h there's a comment that reads:
> /*
>  ...
>  * Note: "mb()" and its variants cannot be used as a fence to order
>  * accesses to memory mapped I/O registers.  For that, mf.a needs to
>  * be used.  However, we don't want to always use mf.a because (a)
>  * it's (presumably) much slower than mf and (b) mf.a is supported for
>  * sequential memory pages only.
>  */
> 
> Is there a macro (e.g. piob() or mmiob()) to wrap mf.a or are users
> expected to call it explicitly when they need it?  If there is no
> macro, I'd like to add one, as I think it will be necessary to
> properly support our NUMA platform.
> 

There is a macro in io.h

	#define __ia64_mf_a()   __asm__ __volatile__ ("mf.a" ::: "memory")


However, it is not clear to me when a mf.a is actually required?? Does
anyone have an opinion?? I dont see any clear need for it. Seems like places
where we might want to use it actually require a flushbus(). 








-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


