From: Michael Ellerman <mpe@ellerman.id.au>
Date: Fri, 11 Oct 2019 06:07:21 +0000
Subject: Re: [PATCH v2 03/29] powerpc: Rename PT_LOAD identifier "kernel" to "text"
Message-Id: <875zkvx1ba.fsf@mpe.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191011000609.29728-1-keescook@chromium.org> <20191011000609.29728-4-keescook@chromium.org>
In-Reply-To: <20191011000609.29728-4-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>, Borislav Petkov <bp@alien8.de>
Cc: Kees Cook <keescook@chromium.org>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Heiko Carstens <heiko.carstens@de.ibm.com>, Will Deacon <will@kernel.org>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-kernel@vger.kernel.org

Kees Cook <keescook@chromium.org> writes:
> In preparation for moving NOTES into RO_DATA, rename the linker script
> internal identifier for the PT_LOAD Program Header from "kernel" to
> "text" to match other architectures.
>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  arch/powerpc/kernel/vmlinux.lds.S | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers

> diff --git a/arch/powerpc/kernel/vmlinux.lds.S b/arch/powerpc/kernel/vmlinux.lds.S
> index a3c8492b2b19..e184a63aa5b0 100644
> --- a/arch/powerpc/kernel/vmlinux.lds.S
> +++ b/arch/powerpc/kernel/vmlinux.lds.S
> @@ -18,7 +18,7 @@
>  ENTRY(_stext)
>  
>  PHDRS {
> -	kernel PT_LOAD FLAGS(7); /* RWX */
> +	text PT_LOAD FLAGS(7); /* RWX */
>  	note PT_NOTE FLAGS(0);
>  }
>  
> @@ -63,7 +63,7 @@ SECTIONS
>  #else /* !CONFIG_PPC64 */
>  		HEAD_TEXT
>  #endif
> -	} :kernel
> +	} :text
>  
>  	__head_end = .;
>  
> @@ -112,7 +112,7 @@ SECTIONS
>  		__got2_end = .;
>  #endif /* CONFIG_PPC32 */
>  
> -	} :kernel
> +	} :text
>  
>  	. = ALIGN(ETEXT_ALIGN_SIZE);
>  	_etext = .;
> @@ -163,9 +163,9 @@ SECTIONS
>  #endif
>  	EXCEPTION_TABLE(0)
>  
> -	NOTES :kernel :note
> +	NOTES :text :note
>  	/* Restore program header away from PT_NOTE. */
> -	.dummy : { *(.dummy) } :kernel
> +	.dummy : { *(.dummy) } :text
>  
>  /*
>   * Init sections discarded at runtime
> @@ -180,7 +180,7 @@ SECTIONS
>  #ifdef CONFIG_PPC64
>  		*(.tramp.ftrace.init);
>  #endif
> -	} :kernel
> +	} :text
>  
>  	/* .exit.text is discarded at runtime, not link time,
>  	 * to deal with references from __bug_table
> -- 
> 2.17.1
