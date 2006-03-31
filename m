From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Date: Fri, 31 Mar 2006 16:37:05 +0000
Subject: Re: [patch] avoid unaligned access when accessing poll stack
Message-Id: <87irpupo3y.fsf@duaron.myhome.or.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0sloytyj5.fsf@jaguar.mkp.net>
In-Reply-To: <yq0sloytyj5.fsf@jaguar.mkp.net> (Jes Sorensen's message of "31 Mar 2006 10:38:22 -0500")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Jes Sorensen <jes@sgi.com> writes:

>   	struct poll_list *walk;
>  	struct fdtable *fdt;
>  	int max_fdset;
> -	/* Allocate small arguments on the stack to save memory and be faster */
> -	char stack_pps[POLL_STACK_ALLOC];
> +	/* Allocate small arguments on the stack to save memory and be 
> +	   faster - use long to make sure the buffer is aligned properly
> +	   on 64 bit archs to avoid unaligned access */
> +	long stack_pps[POLL_STACK_ALLOC/sizeof(long)];
>  	struct poll_list *stack_pp = NULL;

struct poll_list stack_pps[POLL_STACK_ALLOC / sizeof(struct poll_list)];

is more readable, and probably gcc align it rightly?
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
