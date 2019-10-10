From: Borislav Petkov <bp@alien8.de>
Date: Thu, 10 Oct 2019 15:25:16 +0000
Subject: Re: [PATCH 14/29] vmlinux.lds.h: Allow EXCEPTION_TABLE to live in RO_DATA
Message-Id: <20191010152516.GG7658@zn.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190926175602.33098-1-keescook@chromium.org>
 <20190926175602.33098-15-keescook@chromium.org>
In-Reply-To: <20190926175602.33098-15-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Thu, Sep 26, 2019 at 10:55:47AM -0700, Kees Cook wrote:
> Many architectures have an EXCEPTION_TABLE that needs only to be
> read-only. As such, it should live in RO_DATA. This creates a macro to
> identify this case for the architectures that can move EXCEPTION_TABLE
> into RO_DATA.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  include/asm-generic/vmlinux.lds.h | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
> index d57a28786bb8..35a6cba39d9f 100644
> --- a/include/asm-generic/vmlinux.lds.h
> +++ b/include/asm-generic/vmlinux.lds.h
> @@ -69,6 +69,17 @@
>  #define NOTES_HEADERS_RESTORE
>  #endif
>  
> +/*
> + * Some architectures have non-executable read-only exception tables.
> + * They can be added to the RO_DATA segment by specifying their desired
> + * alignment.
> + */
> +#ifdef RO_DATA_EXCEPTION_TABLE_ALIGN
> +#define RO_DATA_EXCEPTION_TABLE	EXCEPTION_TABLE(RO_DATA_EXCEPTION_TABLE_ALIGN)
> +#else
> +#define RO_DATA_EXCEPTION_TABLE
> +#endif
> +
>  /* Align . to a 8 byte boundary equals to maximum function alignment. */
>  #define ALIGN_FUNCTION()  . = ALIGN(8)
>  
> @@ -508,6 +519,7 @@
>  		__stop___modver = .;					\
>  	}								\
>  									\
> +	RO_DATA_EXCEPTION_TABLE						\
>  	NOTES								\
>  									\
>  	. = ALIGN((align));						\
> -- 

I think you can drop the "DATA" from the names as it is kinda clear
where the exception table lands:

RO_EXCEPTION_TABLE_ALIGN
RO_EXCEPTION_TABLE

The "read-only" part is the important one.

-- 
Regards/Gruss,
    Boris.

https://people.kernel.org/tglx/notes-about-netiquette
