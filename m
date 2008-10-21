From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 21 Oct 2008 00:09:25 +0000
Subject: Re: [PATCH 01/35] x86: clean up speedctep-centrino and reduce
Message-Id: <20081021110925.853227d6.sfr@canb.auug.org.au>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Signature=_Tue__21_Oct_2008_11_09_25_+1100_bKpW7.fH4yI8iD3I"
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
	<20081020170319.730428000@polaris-admin.engr.sgi.com>
In-Reply-To: <20081020170319.730428000@polaris-admin.engr.sgi.com>
To: Mike Travis <travis@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>, davej@codemonkey.org.uk, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, IA64 <linux-ia64@vger.kernel.org>, S390 <linux-s390@vger.kernel.org>, peterz@infradead.org, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>, PowerPC <linuxppc-dev@ozlabs.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, SPARC <sparclinux@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>

--Signature=_Tue__21_Oct_2008_11_09_25_+1100_bKpW7.fH4yI8iD3I
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Mike,

Just a first small thing:

On Mon, 20 Oct 2008 10:03:20 -0700 Mike Travis <travis@sgi.com> wrote:
>
> 1) The #ifdef CONFIG_HOTPLUG_CPU seems unnecessary these days.
> 2) The loop can simply skip over offline cpus, rather than creating a tmp=
 mask.
> 3) set_mask is set to either a single cpu or all online cpus in a policy.
>    Since it's just used for set_cpus_allowed(), any offline cpus in a pol=
icy
>    don't matter, so we can just use cpumask_of_cpu() or the policy->cpus.
>=20
> From: Rusty Russell <rusty@rustcorp.com.au>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> Signed-off-by: Mike Travis <travis@sgi.com>

The From: line should be the first nonempty line in the mail to get the
attribution correct.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__21_Oct_2008_11_09_25_+1100_bKpW7.fH4yI8iD3I
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkj9HbUACgkQjjKRsyhoI8y2owCcDEQ+hyOSlFOS93Gg7OnTBzX2
+34Anish918hGHuK+IBMNHs2jq68FpMw
=vM7W
-----END PGP SIGNATURE-----

--Signature=_Tue__21_Oct_2008_11_09_25_+1100_bKpW7.fH4yI8iD3I--
