From: Petr Tesarik <ptesarik@suse.cz>
Date: Wed, 07 Dec 2011 14:22:33 +0000
Subject: Re: Overlapping reserved regions at boot
Message-Id: <201112071522.34034.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201111291501.51657.ptesarik@suse.cz>
In-Reply-To: <201111291501.51657.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Dne =DAt 29. listopadu 2011 15:01:51 Petr Tesarik napsal(a):
> Hello,
>=20
> while working on the upcoming SLES11 SP2, I ran into an issue with booting
> the panic kernel on a kernel crash. In the first iteration I found out
> that the initial register backing store gets overwritten with zeroes,
> causing a kernel crash shortly afterwards.
>=20
> Further investigation revealed that rsvd_region[] contains overlapping
> entries: find_memmap_space() returns a pointer which lies between
> KERNEL_START and _end. This is correct with the EFI memmap as patched by
> the kexec purgatory code. That code removes vmlinux LOAD segments from the
> usable map, but there is a pretty large hole between the gate section and
> the per-cpu section.
>=20
> With the following patch, the panic kernel can boot and save the crash
> dump.

OK guys, I take it that nobody is interested in ia64 any longer, but assumi=
ng=20
that there will probably be no other fix to the issue, can you at least=20
confirm that the fix is acceptable?

TIA,
Petr Tesarik

> Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
>=20
> --- a/arch/ia64/kernel/setup.c
> +++ b/arch/ia64/kernel/setup.c
> @@ -225,6 +225,23 @@
>  	}
>  }
>=20
> +/* merge overlaps */
> +static int __init
> +merge_regions (struct rsvd_region *rsvd_region, int max)
> +{
> +	int i;
> +	for (i =3D 1; i < max; ++i) {
> +		if (rsvd_region[i].start >=3D rsvd_region[i-1].end)
> +			continue;
> +		if (rsvd_region[i].end > rsvd_region[i-1].end)
> +			rsvd_region[i-1].end =3D rsvd_region[i].end;
> +		--max;
> +		memmove(&rsvd_region[i], &rsvd_region[i+1],
> +			(max - i) * sizeof(struct rsvd_region));
> +	}
> +	return max;
> +}
> +
>  /*
>   * Request address space for all standard resources
>   */
> @@ -275,6 +292,7 @@
>  	if (ret =3D 0 && size > 0) {
>  		if (!base) {
>  			sort_regions(rsvd_region, *n);
> +			*n =3D merge_regions(rsvd_region, *n);
>  			base =3D kdump_find_rsvd_region(size,
>  					rsvd_region, *n);
>  		}
> @@ -392,6 +410,7 @@
>  	BUG_ON(IA64_MAX_RSVD_REGIONS + 1 < n);
>=20
>  	sort_regions(rsvd_region, num_rsvd_regions);
> +	num_rsvd_regions =3D merge_regions(rsvd_region, num_rsvd_regions);
>  }
