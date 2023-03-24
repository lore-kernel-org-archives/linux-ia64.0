From: Zi Yan <ziy@nvidia.com>
Date: Fri, 24 Mar 2023 14:28:36 +0000
Subject: Re: [PATCH v2 11/14] sh: reword ARCH_FORCE_MAX_ORDER prompt and help text
Message-Id: <FD865F1A-3878-4829-ADD7-AE4C5E347A9B@nvidia.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=_MailMate_EBE470C3-E8AE-4DE1-A309-2E8D4C914274_="
List-Id: <linux-ia64.vger.kernel.org>
References: <20230324052233.2654090-1-rppt@kernel.org>
 <20230324052233.2654090-12-rppt@kernel.org>
In-Reply-To: <20230324052233.2654090-12-rppt@kernel.org>
To: Mike Rapoport <rppt@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, "David S. Miller" <davem@davemloft.net>, Dinh Nguyen <dinguyen@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Guo Ren <guoren@kernel.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

--=_MailMate_EBE470C3-E8AE-4DE1-A309-2E8D4C914274_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 24 Mar 2023, at 1:22, Mike Rapoport wrote:

> From: "Mike Rapoport (IBM)" <rppt@kernel.org>
>
> The prompt and help text of ARCH_FORCE_MAX_ORDER are not even close to
> describe this configuration option.
>
> Update both to actually describe what this option does.
>
> Signed-off-by: Mike Rapoport (IBM) <rppt@kernel.org>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/sh/mm/Kconfig | 17 +++++++++--------
>  1 file changed, 9 insertions(+), 8 deletions(-)
>
> diff --git a/arch/sh/mm/Kconfig b/arch/sh/mm/Kconfig
> index 40271090bd7d..fb15ba1052ba 100644
> --- a/arch/sh/mm/Kconfig
> +++ b/arch/sh/mm/Kconfig
> @@ -19,8 +19,7 @@ config PAGE_OFFSET
>  	default "0x00000000"
>
>  config ARCH_FORCE_MAX_ORDER
> -	int "Maximum zone order"
> -	range 8 63 if PAGE_SIZE_16KB

This range is dropped in current patch, but the other ranges are dropped =
in
the next patch. But feel free to ignore this since ultimately the ranges
are all dropped.

> +	int "Order of maximal physically contiguous allocations"
>  	default "8" if PAGE_SIZE_16KB
>  	range 6 63 if PAGE_SIZE_64KB
>  	default "6" if PAGE_SIZE_64KB
> @@ -28,16 +27,18 @@ config ARCH_FORCE_MAX_ORDER
>  	default "13" if !MMU
>  	default "10"
>  	help
> -	  The kernel memory allocator divides physically contiguous memory
> -	  blocks into "zones", where each zone is a power of two number of
> -	  pages.  This option selects the largest power of two that the kerne=
l
> -	  keeps in the memory allocator.  If you need to allocate very large
> -	  blocks of physically contiguous memory, then you may need to
> -	  increase this value.
> +	  The kernel page allocator limits the size of maximal physically
> +	  contiguous allocations. The limit is called MAX_ORDER and it
> +	  defines the maximal power of two of number of pages that can be
> +	  allocated as a single contiguous block. This option allows
> +	  overriding the default setting when ability to allocate very
> +	  large blocks of physically contiguous memory is required.
>
>  	  The page size is not necessarily 4KB. Keep this in mind when
>  	  choosing a value for this option.
>
> +	  Don't change if unsure.
> +
>  config MEMORY_START
>  	hex "Physical memory start address"
>  	default "0x08000000"
> -- =

> 2.35.1


--
Best Regards,
Yan, Zi

--=_MailMate_EBE470C3-E8AE-4DE1-A309-2E8D4C914274_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQJDBAEBCgAtFiEE6rR4j8RuQ2XmaZol4n+egRQHKFQFAmQds5QPHHppeUBudmlk
aWEuY29tAAoJEOJ/noEUByhU6+sQAJM0BaoLQ3JYR+tN4yC8YqhEBdUlGAiar2eu
amh3KB7M4ygrGx4ivtA/P7dJtCyBDC7LQcpamgwUUGLEeUbxD0O5SPmctZz7Z+ER
awE6TdkjuecDXdm2G5WB4OC/FUFWJ/kHar6eaGSybjQzg31LiU0pOAJus8l0l9v/
PTlEdBnB+XVp6E6TVHafnNai3twlKguqamkAjDpaINar97BtNMuXPDBcBKXeS+RK
9FvK/kWOO8ZpLu1N0RMAYaBEmBtZKedErzKTOzRzM0WwpqTVzWy1gwUmiqKxWr15
OrGrLLzjGcekWkyfRXOC48H/CLWDGZJNE+kElE8vW/cKl2tFhw0aS2RjxvKspYDF
sEdf3jiO9eq4u5nxIgkxc+7Ub+NFruZhPEnfcN5b8yK0I+n6rvdA9+HtQKqDqTAz
VC2HtBqKZKvV5q6hBJFSwBaOKkc7r9/3byaOJsJB50+kNpJkL4O643MUCZlXlf1q
3/X5yMLNC6HtFWfLNUz3TjaJnEuVmqhzulFi1ejm1eN7hJV65xZBgSTpOAA62X2J
hjGWuTQIXclo15ysx94I+oDW9KlIT+Uj4GMY/6sGUNvhPvwXIuKgvvSOsG7YubF2
/IUUoi0yQCXK+NpcdG3nYMosWesxpGrT2Q6Ou0hTbfylUIlnWUput4ARcFqwt5uQ
MLJrryCO
=cDus
-----END PGP SIGNATURE-----

--=_MailMate_EBE470C3-E8AE-4DE1-A309-2E8D4C914274_=--
