From: Andreas Schwab <schwab@suse.de>
Date: Thu, 13 Apr 2006 08:05:17 +0000
Subject: Re: Make show_mem() skip holes in a pgdat.
Message-Id: <jeek01j3ya.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060413031519.GB2678@lnx-holt.americas.sgi.com>
In-Reply-To: <20060413031519.GB2678@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Robin Holt <holt@sgi.com> writes:

> Index: linux-2.6/arch/ia64/mm/discontig.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.orig/arch/ia64/mm/discontig.c	20=
06-04-12 18:20:44.374700839 -0500
> +++ linux-2.6/arch/ia64/mm/discontig.c	2006-04-12 22:11:31.971106982 -0500
> @@ -547,8 +547,71 @@ void show_mem(void)
>  			struct page *page;
>  			if (pfn_valid(pgdat->node_start_pfn + i))
>  				page =3D pfn_to_page(pgdat->node_start_pfn + i);
> -			else
> +			else {
> +				/*
> +				 * At the beginning of a hole. Search vmem_map
> +				 * page tables for the end.
> +				 */
> +				unsigned long end_address, hole_end_pfn;
> +				unsigned long stop_address;
> +
> +				end_address =3D (unsigned long) &vmem_map[pgdat->node_start_pfn + i];
> +				end_address =3D PAGE_ALIGN(end_address);
> +
> +				stop_address =3D (unsigned long) &vmem_map[
> +					pgdat->node_start_pfn + pgdat->node_spanned_pages];

When you need more than 3 levels of indentation you should factor it out
into an inline function.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
