From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 05 Jun 2009 09:26:33 +0000
Subject: Re: [PATCH 2/6] headers_check fix: ia64, fpswa.h
Message-Id: <200906051026.34046.arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1244118232.5172.26.camel@ht.satnam> <1244118476.5172.29.camel@ht.satnam> <1244118599.5172.31.camel@ht.satnam>
In-Reply-To: <1244118599.5172.31.camel@ht.satnam>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jaswinder Singh Rajput <jaswinder@kernel.org>
Cc: Sam Ravnborg <sam@ravnborg.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

On Thursday 04 June 2009, Jaswinder Singh Rajput wrote:

> index 62edfce..797b064 100644
> --- a/arch/ia64/include/asm/fpswa.h
> +++ b/arch/ia64/include/asm/fpswa.h
> @@ -68,6 +68,7 @@ typedef struct {
>  	efi_fpswa_t	 fpswa;
>  } fpswa_interface_t;
>  
> +#ifdef __KERNEL__
>  extern fpswa_interface_t *fpswa_interface;
> -
> +#endif
>  #endif /* _ASM_IA64_FPSWA_H */

It's pretty obvious that the above data structure also doesn't
apply in user space. In fact it looks like the whole file should
just not be exported. Your patch is not helpful there because
it just silences the warning.

	Arnd <><
