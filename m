From: Michael Ellerman <michael@ellerman.id.au>
Date: Mon, 24 Aug 2009 13:44:03 +0000
Subject: Re: [Patch 6/8] powerpc: add CONFIG_KEXEC_AUTO_RESERVE
Message-Id: <1251121443.10645.56.camel@concordia>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-Io39234LEQW+b+fdpE6S"
List-Id: <linux-ia64.vger.kernel.org>
References: <20090821065637.4855.32234.sendpatchset@localhost.localdomain>
	 <20090821065739.4855.19179.sendpatchset@localhost.localdomain>
In-Reply-To: <20090821065739.4855.19179.sendpatchset@localhost.localdomain>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, kamezawa.hiroyu@jp.fujitsu.com, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>


--=-Io39234LEQW+b+fdpE6S
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-08-21 at 02:55 -0400, Amerigo Wang wrote:
> Introduce a new config option KEXEC_AUTO_RESERVE for powerpc.
>=20
> Index: linux-2.6/arch/powerpc/Kconfig
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/arch/powerpc/Kconfig
> +++ linux-2.6/arch/powerpc/Kconfig
> @@ -346,6 +346,17 @@ config KEXEC
>  	  support.  As of this writing the exact hardware interface is
>  	  strongly in flux, so no good recommendation can be made.
> =20
> +config KEXEC_AUTO_RESERVE
> +	bool "automatically reserve memory for kexec kernel"
> +	depends on KEXEC
> +	default y
> +	---help---
> +	  Automatically reserve memory for a kexec kernel, so that you don't
> +	  need to specify numbers for the "crashkernel=3DX@Y" boot option,
> +	  instead you can use "crashkernel=3Dauto". To make this work, you need
> +	  to have more than 4G memory. On PPC, 256M is reserved, 1/32 memory
> +	  on PPC64, but it will not exceed 1T/32.

To be honest I don't see why this logic goes in the kernel. It seems to
me that it's policy how much memory you devote to the crash kernel vs
the production kernel. It depends on what kind of crash kernel you're
loading, a minimal UP dump kernel, or a full-featured SMP behemoth, An
it depends on how much memory you're willing to leave idle in the
off-chance you crash.

That aside, I don't see how this will be useful in practice, if it only
works for memory sizes over 4G? Or are we saying that people with less
than 4G don't need crash kernels? If we're not saying that, those users,
or those users' distros, still need to do some logic to work out if they
have < 4GB of memory and if so pick a crash kernel size. So why can't
they pick the size in the > 4GB case also?

Also the numbers seem a bit arbitrary. 4GB ? 256M ? 1/32?  I don't think
we really want to be blowing 32GB on a crash kernel, even if we do have
1T of RAM :)

cheers



--=-Io39234LEQW+b+fdpE6S
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkqSmSMACgkQdSjSd0sB4dIYZACdEjqjz1MY6jN9Rl4rCbTS7Fpa
4xAAnjIVTnikpRn/PSmkK8YfCnbcNGCS
=ECts
-----END PGP SIGNATURE-----

--=-Io39234LEQW+b+fdpE6S--

