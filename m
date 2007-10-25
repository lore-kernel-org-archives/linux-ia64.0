From: Doug Chapman <dchapman@redhat.com>
Date: Thu, 25 Oct 2007 16:10:38 +0000
Subject: Re: [PATCH] ia64: check-segrel.lds vs --build-id
Message-Id: <1193328638.7591.10.camel@deimos.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071018195453.A34D64D04E2@magilla.localdomain>
In-Reply-To: <20071018195453.A34D64D04E2@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 2007-10-18 at 12:54 -0700, Roland McGrath wrote:
> Some versions of ld with --build-id support will crash when using the flag
> with a linker script that discards notes.  This bites ia64's check-segrel.lds.
> The bug is easy to avoid.
> 
> Signed-off-by: Roland McGrath <roland@redhat.com>
> 
> --- a/arch/ia64/scripts/check-segrel.lds
> +++ b/arch/ia64/scripts/check-segrel.lds
> @@ -1,6 +1,7 @@
>  SECTIONS {
>  	. = SIZEOF_HEADERS;
>  	.rodata : { *(.rodata) } :ro
> +	.note : { *(.note*) }
>  	. = 0xa0000;
>  	.data : { *(.data) } :dat
>  	/DISCARD/ : { *(*) }
> 
> -

This patch is not yet in the git tree.  This, along with the patch to
gate.lds.S that Roland submitted are both blocking our bringup of Fedora
on ia64.

thanks,

- Doug


