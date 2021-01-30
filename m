From: Joe Perches <joe@perches.com>
Date: Sat, 30 Jan 2021 18:55:24 +0000
Subject: Re: [PATCH 03/29] ia64: Avoid comma separated statements
Message-Id: <bfac54e37f602bcdac73f6aee4e9fcd4fd651795.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1598331148.git.joe@perches.com>
         <be37cf8fdcad19678cd164946252bc67713ddcdf.1598331148.git.joe@perches.com>
In-Reply-To: <be37cf8fdcad19678cd164946252bc67713ddcdf.1598331148.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Jiri Kosina <trivial@kernel.org>, linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Mon, 2020-08-24 at 21:56 -0700, Joe Perches wrote:
> Use semicolons and braces.

ping?


> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> =A0arch/ia64/kernel/smpboot.c | 7 +++++--
> =A01 file changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
> index c29c600d7967..3311b9d21319 100644
> --- a/arch/ia64/kernel/smpboot.c
> +++ b/arch/ia64/kernel/smpboot.c
> @@ -224,8 +224,11 @@ get_delta (long *rt, long *master)
> =A0		go[SLAVE] =3D 0;
> =A0		t1 =3D ia64_get_itc();
> =A0
>=20
> -		if (t1 - t0 < best_t1 - best_t0)
> -			best_t0 =3D t0, best_t1 =3D t1, best_tm =3D tm;
> +		if (t1 - t0 < best_t1 - best_t0) {
> +			best_t0 =3D t0;
> +			best_t1 =3D t1;
> +			best_tm =3D tm;
> +		}
> =A0	}
> =A0
>=20
> =A0	*rt =3D best_t1 - best_t0;

