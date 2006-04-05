From: Andreas Schwab <schwab@suse.de>
Date: Wed, 05 Apr 2006 21:39:16 +0000
Subject: Re: 2.6.17-rc1-mm1
Message-Id: <jer74b7ldn.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060404014504.564bf45a.akpm@osdl.org>
	<20060404233851.GA6411@agluck-lia64.sc.intel.com>
	<1144202706.3197.11.camel@linux-znh>
	<200604051015.34217.bjorn.helgaas@hp.com>
	<20060405211757.GA8536@agluck-lia64.sc.intel.com>
In-Reply-To: <20060405211757.GA8536@agluck-lia64.sc.intel.com> (Tony Luck's
	message of "Wed, 5 Apr 2006 14:17:57 -0700")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, Zou Nan hai <nanhai.zou@intel.com>, Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

> diff --git a/drivers/video/console/vgacon.c b/drivers/video/console/vgaco=
n.c
> index d5a04b6..4ca9877 100644
> --- a/drivers/video/console/vgacon.c
> +++ b/drivers/video/console/vgacon.c
> @@ -484,8 +484,8 @@ #endif
>  	}
> =20
>  	vga_vram_base =3D VGA_MAP_MEM(vga_vram_base);
> -	vga_vram_end =3D VGA_MAP_MEM(vga_vram_end);
> -	vga_vram_size =3D vga_vram_end - vga_vram_base;
> +	vga_vram_end =3D VGA_MAP_MEM(vga_vram_end - 1);
> +	vga_vram_size =3D vga_vram_end - vga_vram_base + 1;

Better use vga_vram_end =3D VGA_MAP_MEM(vga_vram_end - 1) + 1, or you'll
screw up the other computations using vga_vram_end.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
