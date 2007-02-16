From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 16 Feb 2007 22:48:35 +0000
Subject: Re: [PATCH] Remove stack hard limit on ia64
Message-Id: <20070216144835.711f7c54.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070216220654.GA11135@aepfle.de>
In-Reply-To: <20070216220654.GA11135@aepfle.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Olaf Hering <olaf@aepfle.de>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, schwab@suse.de

On Fri, 16 Feb 2007 23:06:54 +0100
Olaf Hering <olaf@aepfle.de> wrote:

> From: schwab@suse.de
> 
> Un-Breaks pthreads, since Oct 2003.
> 

Oh come on, that's not a changelog.  I refuse to believe that nobody has
used pthreads on ia64 for the past three years.

> 
> Index: linux-2.6/include/asm-ia64/resource.h
> =================================> --- linux-2.6.orig/include/asm-ia64/resource.h
> +++ linux-2.6/include/asm-ia64/resource.h
> @@ -2,7 +2,6 @@
>  #define _ASM_IA64_RESOURCE_H
>  
>  #include <asm/ustack.h>
> -#define _STK_LIM_MAX	DEFAULT_USER_STACK_SIZE
>  #include <asm-generic/resource.h>
>  
>  #endif /* _ASM_IA64_RESOURCE_H */

Please provide a complete description of the problem which this patch is
fixing, and a complete description of how the patch fixes it.
