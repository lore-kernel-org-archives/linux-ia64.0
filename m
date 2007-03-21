From: Andreas Schwab <schwab@suse.de>
Date: Wed, 21 Mar 2007 22:39:06 +0000
Subject: Re: [patch 5/5] ia64: update memory attribute aliasing documentation & test cases
Message-Id: <je648up6gl.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200703211622.26630.bjorn.helgaas@hp.com>
In-Reply-To: <200703211622.26630.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Bjorn Helgaas <bjorn.helgaas@hp.com> writes:

> @@ -138,14 +128,20 @@
> =20
>      ioremap()
> =20
> -	This returns a kernel identity mapping for use inside the
> -	kernel.
> +	This returns a mapping for use inside the kernel.
> =20
>  	If the region is in kern_memmap, we should use the attribute
> -	specified there.  Otherwise, if the EFI memory map reports that
> -	the entire granule supports WB, we should use that (granules
> -	that are partially reserved or occupied by firmware do not appear
> -	in kern_memmap).  Otherwise, we should use a UC mapping.
> +	specified there.
> +
> +	If the EFI memory map reports that the entire granule supports
> +	WB, we should use that (granules that are partially reserved
> +	or occupied by firmware do not appear in kern_memmap).
> +
> +	If the granule contains non-WB memory, but we can cover the
> +	region safely with kernel page table mappings, we can use
> +	ioremap_page_range() as most other architectures do.
> +
> +	Failing all of the above, we have to all back to a UC mapping.

s/all back/fall back/

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
