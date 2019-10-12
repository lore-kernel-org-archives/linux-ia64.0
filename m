From: Helge Deller <deller@gmx.de>
Date: Sat, 12 Oct 2019 09:50:09 +0000
Subject: Re: [PATCH v2 23/29] parisc: Move EXCEPTION_TABLE to RO_DATA segment
Message-Id: <8b3c27ec-9880-5957-a802-ca740d9ad6c5@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191011000609.29728-1-keescook@chromium.org>
 <20191011000609.29728-24-keescook@chromium.org>
In-Reply-To: <20191011000609.29728-24-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>, Borislav Petkov <bp@alien8.de>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Michael Ellerman <mpe@ellerman.id.au>, Heiko Carstens <heiko.carstens@de.ibm.com>, Will Deacon <will@kernel.org>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On 11.10.19 02:06, Kees Cook wrote:
> Since the EXCEPTION_TABLE is read-only, collapse it into RO_DATA.
>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>   arch/parisc/kernel/vmlinux.lds.S | 4 +---
>   1 file changed, 1 insertion(+), 3 deletions(-)


Acked-by: Helge Deller <deller@gmx.de>  # parisc

Helge

>
> diff --git a/arch/parisc/kernel/vmlinux.lds.S b/arch/parisc/kernel/vmlinux.lds.S
> index 12b3d7d5e9e4..53e29d88f99c 100644
> --- a/arch/parisc/kernel/vmlinux.lds.S
> +++ b/arch/parisc/kernel/vmlinux.lds.S
> @@ -19,6 +19,7 @@
>   				*(.data..vm0.pte)
>
>   #define CC_USING_PATCHABLE_FUNCTION_ENTRY
> +#define RO_EXCEPTION_TABLE_ALIGN	8
>
>   #include <asm-generic/vmlinux.lds.h>
>
> @@ -129,9 +130,6 @@ SECTIONS
>
>   	RO_DATA(8)
>
> -	/* RO because of BUILDTIME_EXTABLE_SORT */
> -	EXCEPTION_TABLE(8)
> -
>   	/* unwind info */
>   	.PARISC.unwind : {
>   		__start___unwind = .;
>
