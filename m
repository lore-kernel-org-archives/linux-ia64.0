From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Sat, 20 Apr 2019 17:07:50 +0000
Subject: Re: [PATCH] ia64: agp: Replace empty define with do while
Message-Id: <20190420170750.GA23311@Red>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171220191613.7827-1-clabbe.montjoie@gmail.com>
In-Reply-To: <20171220191613.7827-1-clabbe.montjoie@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: fenghua.yu@intel.com, tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 20, 2017 at 08:16:13PM +0100, Corentin Labbe wrote:
> It's dangerous to use empty code define.
> Furthermore it lead to the following warning:
> drivers/char/agp/generic.c: In function =AB=A0agp_generic_destroy_page=A0=
=BB:
> drivers/char/agp/generic.c:1266:28: attention : suggest braces around emp=
ty body in an =AB=A0if=A0=BB statement [-Wempty-body]
>=20
> So let's replace emptyness by "do {} while(0)"
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Hello

Gentle ping

Regards

> ---
>  arch/ia64/include/asm/agp.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/arch/ia64/include/asm/agp.h b/arch/ia64/include/asm/agp.h
> index 2b451c4496da..0261507dc264 100644
> --- a/arch/ia64/include/asm/agp.h
> +++ b/arch/ia64/include/asm/agp.h
> @@ -14,8 +14,8 @@
>   * in coherent mode, which lets us map the AGP memory as normal (write-b=
ack) memory
>   * (unlike x86, where it gets mapped "write-coalescing").
>   */
> -#define map_page_into_agp(page)		/* nothing */
> -#define unmap_page_from_agp(page)	/* nothing */
> +#define map_page_into_agp(page)		do { } while (0)
> +#define unmap_page_from_agp(page)	do { } while (0)
>  #define flush_agp_cache()		mb()
> =20
>  /* GATT allocation. Returns/accepts GATT kernel virtual address. */
> --=20
> 2.13.6
>=20
