From: Arjan van de Ven <arjan@infradead.org>
Date: Wed, 28 Jun 2006 08:39:54 +0000
Subject: Re: [PATCH] ia64: change usermode HZ to 250
Message-Id: <1151483994.3153.5.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060627220139.3168.69409.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20060627220139.3168.69409.sendpatchset@tomahawk.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hawkes@sgi.com
Cc: Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, Jeremy Higdon <jeremy@sgi.com>

On Tue, 2006-06-27 at 15:01 -0700, hawkes@sgi.com wrote:
> include/asm-ia64/param.h defines HZ to be 1024 for usermode use, i.e.,
> when the file gets installed as /usr/include/asm/param.h.
> As the comment says:
>     Technically, this is wrong, but some old apps still refer to it.  
>     The proper way to get the HZ value is via sysconf(_SC_CLK_TCK).
> At the very least, this technically wrong #define ought to reflect the
> current default value (250) used by all arch/ia64 platforms.  No one uses
> 1024 anymore.  This makes those "old apps" (e.g., usr/bin/iostat) behave
> properly for with a default kernel.  (And at some point, the define ought
> to be removed altogether, which would expose all the applications that
> erroneously expect HZ to be a compile-time constant.)
> 
> Signed-off-by: John Hawkes <hawkes@sgi.com>
> 
> Index: linux/include/asm-ia64/param.h
> =================================> --- linux.orig/include/asm-ia64/param.h	2006-06-17 18:49:35.000000000 -0700
> +++ linux/include/asm-ia64/param.h	2006-06-27 14:46:53.119407077 -0700
> @@ -36,7 +36,7 @@
>      * Technically, this is wrong, but some old apps still refer to it.  The proper way to
>      * get the HZ value is via sysconf(_SC_CLK_TCK).
>      */
> -# define HZ 1024
> +# define HZ 250
>  #endif

ok why not define the userspace HZ to 

#define HZ sysconf(_SC_CLK_TCK)

?


