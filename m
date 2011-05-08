From: Sven Eckelmann <sven@narfation.org>
Date: Sun, 08 May 2011 09:33:48 +0000
Subject: Re: [PATCH] atomic: add *_dec_not_zero
Message-Id: <201105081133.50824.sven@narfation.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart1677856.Ey88dTAy4V"
List-Id: <linux-ia64.vger.kernel.org>
References: <1304458235-28473-1-git-send-email-sven@narfation.org> <20110508092403.GB27807@n2100.arm.linux.org.uk>
In-Reply-To: <20110508092403.GB27807@n2100.arm.linux.org.uk>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-m32r@ml.linux-m32r.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-cris-kernel@axis.com, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, x86@kernel.org, Chris Metcalf <cmetcalf@tilera.com>, David Howells <dhowells@redhat.com>, linux-m68k@lists.linux-m68k.org, linux-am33-list@redhat.com, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

--nextPart1677856.Ey88dTAy4V
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Russell King - ARM Linux wrote:
[...]
> Do we need atomic_dec_not_zero() et.al. in every arch header - is there no
> generic header which it could be added to?

Mike Frysinger already tried to answer it in=20
<BANLkTimctgbto3dsnJ3d3r7NggS0KF9_Sw@mail.gmail.com>:
> that's what asm-generic is for.  if the arch isnt using it, it's
> either because the arch needs to convert to it, or they're using SMP
> and asm-generic doesnt yet support that for atomic.h.
>
> for example, the Blackfin port only needed updating for the SMP case.
> in the non-SMP case, we're getting the def from asm-generic/atomic.h.
> -mike

=46eel free to change that but I just followed the style used by all other=
=20
macros and will not redesign the complete atomic*.h idea.

thanks,
	Sven

--nextPart1677856.Ey88dTAy4V
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJNxmN9AAoJEF2HCgfBJntGmosP/0BjDtvk4ZKsL9hhonb8gZ4t
/2/hY6jeQ3Mg30Z1v6+PIZDun17qML5ODBcTB72oJs1LujHyEgNKKtfQ9stYgAm3
79B2UAH5LYVzZzd2j5nMWemGYChUXl5v5N/hOFOp04ImC7DU27fwadcuO+q47vnS
kKvrnccIFc0qUpnGwZ+1rqHIp9Rs3AQHjvyxaUDIuMs8ZWurYkS+e5SMini7qUpe
QvsTQVZhyuNtemvZUzrWUcftMVPNXxTHwwV5aALBswX4SPreBJWX33b8j+NIHeFU
hmwZ7/RzuDCyIzUFmeeXj/f0RCbWv5XkhQmNaCGFBdatgLRd2fnDOXzkuOeUPtBi
SX2jkxoXSMGwEtl2mzOW8JhvcGrG1+oMw9j/BqdQyaQe0rRnuFg962eRUs1RvibI
bej/DRfMexoXhlw7EIN9JGoniuMAW88Ws4RB79HuPURy6Ax1cr87ELH/Oj5ZvlOc
+whWNM9JuDFamC9E4zaenxqf0jd3mlvCAMaljh66J7qECJF9xWd5eJyet7CE7/hp
kE6iUT6Zf93Na9NImeTTeGK16LW1KqLkP8QyI+HUGO7A5wj/QvubGPBO0deHsp8G
YkQBcQwZMSft69hsW2Ke1btpJv/ScGxeVuplmMNrlDa1hAqjm+aHo6+xxTS5Mp72
p5S21fQTeEf4fOJsQubR
=ICmm
-----END PGP SIGNATURE-----

--nextPart1677856.Ey88dTAy4V--
