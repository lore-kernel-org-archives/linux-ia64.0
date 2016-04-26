From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Date: Tue, 26 Apr 2016 22:07:47 +0000
Subject: Re: [PATCH 6/8] char/genrtc: parisc: use asm-generic/rtc.h
Message-Id: <3034953.EvqV1iv2Ef@caliban.sf-tec.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart1484825.uGIj57kKZR"
List-Id: <linux-ia64.vger.kernel.org>
References: <1461707052-1337718-1-git-send-email-arnd@arndb.de> <1461707052-1337718-7-git-send-email-arnd@arndb.de>
In-Reply-To: <1461707052-1337718-7-git-send-email-arnd@arndb.de>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, tony.luck@intel.com, geert@linux-m68k.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, mpe@ellerman.id.au, dalias@libc.org, dhowells@redhat.com, yasutake.koichi@jp.panasonic.com, rth@twiddle.net, ink@jurassic.park.msu.ru, linux-alpha@vger.kernel.org, x86@kernel.org, a.zummo@towertech.it, alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, rtc-linux@googlegroups.com, linux-arch@vger.kernel.org

--nextPart1484825.uGIj57kKZR
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Arnd Bergmann wrote:
> The asm-generic/rtc.h header can now be included by
> architectures that provide their own set_rtc_time/get_rtc_time
> macros, letting us remove most of the common contents in
> the powerpc implementation.

parisc in this case.

Eike
--nextPart1484825.uGIj57kKZR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEABECAAYFAlcf5rgACgkQXKSJPmm5/E4XHQCfYLbFGGoGa3RONzYALJ5wXGhV
eswAoJzCfTkDFm06E5j/I7xKraT4hn9i
=TRZX
-----END PGP SIGNATURE-----

--nextPart1484825.uGIj57kKZR--

