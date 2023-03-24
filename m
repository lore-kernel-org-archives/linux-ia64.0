From: Zi Yan <ziy@nvidia.com>
Date: Fri, 24 Mar 2023 13:48:49 +0000
Subject: Re: [PATCH v2 03/14] arm64: reword ARCH_FORCE_MAX_ORDER prompt and help text
Message-Id: <0D106E04-A043-45B0-8629-11DC10127FD8@nvidia.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=_MailMate_C127E265-4DDB-40BB-87AD-DB2006154019_="
List-Id: <linux-ia64.vger.kernel.org>
References: <20230324052233.2654090-1-rppt@kernel.org>
 <20230324052233.2654090-4-rppt@kernel.org>
In-Reply-To: <20230324052233.2654090-4-rppt@kernel.org>
To: Mike Rapoport <rppt@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, "David S. Miller" <davem@davemloft.net>, Dinh Nguyen <dinguyen@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Guo Ren <guoren@kernel.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

--=_MailMate_C127E265-4DDB-40BB-87AD-DB2006154019_=
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
>  arch/arm64/Kconfig | 24 ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)
>
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 7324032af859..cdaf52ac4018 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -1487,24 +1487,24 @@ config XEN
>  # 16K |       27          |      14      |       13        |         1=
1         |
>  # 64K |       29          |      16      |       13        |         1=
3         |
>  config ARCH_FORCE_MAX_ORDER
> -	int "Maximum zone order" if EXPERT && (ARM64_4K_PAGES || ARM64_16K_PA=
GES)
> +	int "Order of maximal physically contiguous allocations" if ARM64_4K_=
PAGES || ARM64_16K_PAGES

It seems that "if EXPERT" was dropped by accident here.

>  	default "13" if ARM64_64K_PAGES
>  	default "11" if ARM64_16K_PAGES
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
> -	  We make sure that we can allocate up to a HugePage size for each co=
nfiguration.
> -	  Hence we have :
> -		MAX_ORDER =3D PMD_SHIFT - PAGE_SHIFT  =3D> PAGE_SHIFT - 3
> +	  The maximal size of allocation cannot exceed the size of the
> +	  section, so the value of MAX_ORDER should satisfy
>
> -	  However for 4K, we choose a higher default value, 10 as opposed to =
9, giving us
> -	  4M allocations matching the default size used by generic code.
> +	    MAX_ORDER + PAGE_SHIFT <=3D SECTION_SIZE_BITS
> +
> +	  Don't change if unsure.
>
>  config UNMAP_KERNEL_AT_EL0
>  	bool "Unmap kernel when running in userspace (aka \"KAISER\")" if EXP=
ERT
> -- =

> 2.35.1


--
Best Regards,
Yan, Zi

--=_MailMate_C127E265-4DDB-40BB-87AD-DB2006154019_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQJDBAEBCgAtFiEE6rR4j8RuQ2XmaZol4n+egRQHKFQFAmQdqkEPHHppeUBudmlk
aWEuY29tAAoJEOJ/noEUByhUwaIP/RG0bciGb3wj5HWQeRaRqWKWcktYcPQ7w4Dh
2pGQeKuSL51RphMV2eO9lDSw0fmEyRTvCWVHKaMCD/9leDkY5chAmu7jpb1IUPTp
3jK8kg56Iepg13Gx3EWW1KDE2y/3GarCF6JcVvSuVb0yVsP70XPbMHoS7qgI6WjN
vs14YoCZRPSA5OaCRDmrh7bc4UXkU7Biwsg8DiOsZcnjMFm3HJgafOhLQ57UWtQF
f6g/uls+c+s1BtCGgZ48iygBq1oJeVn30IkXU/+LeEPGj6qLUXJAcXqTHEXmaW8h
tbzaHVog1hMjOYuUoCfH+YAgKQ833P19IST6L2CsGh+LQZC3oPUBA7N2HGVa1RtL
YNkHl4nKsh3yX5TxNadzMdfldoW3oBho0GnxaL93gFknFl+sEudEf7ExRJeXaFjo
rCVelBEyVCfr0k6pngXCCfs/lw4SYqTb+k+ZbxA+WIgaTqOMUe62wThNnfHrENy6
OKX6UltE6o5l5XbF3T12cmWemZzBWwOVGpWSUxoImM1isuYl+6DmAbZdcDBImY80
lLTKlsK7uc9GfQfOmTCicDT9yTR16alIuxP262DfQryqYcwmHqjDwLLyk1JmdRYp
/o94M++puGJfVSMk/3fBkmvVjH/4+J18ZQ/hW4F1pCWz9OSik+y1bOfSovihFeyB
46TBIGnB
=WRnA
-----END PGP SIGNATURE-----

--=_MailMate_C127E265-4DDB-40BB-87AD-DB2006154019_=--
