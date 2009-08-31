From: Michael Ellerman <michael@ellerman.id.au>
Date: Mon, 31 Aug 2009 00:54:56 +0000
Subject: Re: [Patch 0/8] V5 Implement crashkernel=auto
Message-Id: <1251680096.5279.6.camel@concordia>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-j9EEpo+dHFhto0hRq2AN"
List-Id: <linux-ia64.vger.kernel.org>
References: <20090827031800.4534.94868.sendpatchset@localhost.localdomain>
In-Reply-To: <20090827031800.4534.94868.sendpatchset@localhost.localdomain>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, kamezawa.hiroyu@jp.fujitsu.com, Andi Kleen <andi@firstfloor.org>, "M. Mohan Kumar" <mohan@in.ibm.com>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>


--=-j9EEpo+dHFhto0hRq2AN
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-08-26 at 23:15 -0400, Amerigo Wang wrote:
> V4 -> V5:
>  - Rename the global functions, as suggested by Andrew.
>  - Save some macros, as suggested by Andrew.
>  - Change the high threshold, from 32G to 4G.
>  - Change the low threshold on ppc, suggested by ppc developers.
>  - Make the mm part as a seperate function, suggest by Eric.
>  - Make the IA64 code more readable.
>  - Reorder the patchset again, since review from mm people is done.
>=20
> V3 -> V4:
>  - Reorder the patches.
>  - Really free the reserved memory, instead of remapping it.
>    (Thanks to KAMEZAWA Hiroyuki!)
>  - Release the reserved memory resource when the size is 0.
>  - Use strict_strtoul() instead of simple_strtoul().
>=20
> V2 -> V3:
>  - Use more clever way to calculate reserved memory size, especially for =
IA64.
>  - Add that patch that implements shrinking reserved memory
>=20
> V1 -> V2:
>  - Use include/asm-generic/kexec.h, suggested by Neil.
>  - Rename a local variable, suggested by Fenghua.
>  - Fix some style problems found by checkpatch.pl.
>  - Unify the Kconfig docs.
>=20
> This series of patch implements automatically reserved memory for crashke=
rnel,
> by introducing a new boot option "crashkernel=3Dauto". This idea is from =
Neil.
>=20
> In case of breaking user-space applications, it modifies this boot option=
 after
> it decides how much memory should be reserved.
>=20
> On different arch, the threshold and reserved memory size is different. P=
lease
> refer patch 7/8 which contains an update for the documentation.
>=20
> Patch 8/8 implements shrinking reserved memory at run-time, which is usef=
ul
> when more than enough memory is reserved automatically.
>=20
> This patchset _is_ already tested on x86_64, IA64 and ppc64.

I don't want to sound like a micro-kernel zealot, I'm not, but I'm still
unconvinced as to why the auto logic needs to go in the kernel. What is
the compelling reason that the kernel needs to do this calculation vs
some userspace tool? We already have the syntax that allows defining a
different crash size depending on the size of RAM.

The shrinking of reserved memory is cool.

cheers

--=-j9EEpo+dHFhto0hRq2AN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkqbH10ACgkQdSjSd0sB4dJaxwCgsfE86zo4J6zXMwhsgkoUEeKo
6kEAn1dFOuXTv6RBw8cM3k3yr1fPawLH
=yOoo
-----END PGP SIGNATURE-----

--=-j9EEpo+dHFhto0hRq2AN--

