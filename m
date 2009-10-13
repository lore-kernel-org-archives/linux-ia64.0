From: Michael Ellerman <michael@ellerman.id.au>
Date: Tue, 13 Oct 2009 21:54:47 +0000
Subject: Re: [PATCH 2/8] bitmap: Introduce bitmap_set, bitmap_clear,
Message-Id: <1255470887.21871.2.camel@concordia>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-qc5/2QIIQzGbB3R6aIJb"
List-Id: <linux-ia64.vger.kernel.org>
References: <1255076961-21325-1-git-send-email-akinobu.mita@gmail.com>
	 <1255076961-21325-2-git-send-email-akinobu.mita@gmail.com>
	 <20091009164100.85a36188.akpm@linux-foundation.org>
	 <20091013021818.GA3898@localhost.localdomain>
	 <20091013091017.GA18431@localhost.localdomain>
In-Reply-To: <20091013091017.GA18431@localhost.localdomain>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@suse.de>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, x86@kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-altix@sgi.com, Yevgeny Petrilin <yevgenyp@mellanox.co.il>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linuxppc-dev@ozlabs.org, Ingo Molnar <mingo@redhat.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-usb@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Lothar Wassmann <LW@KARO-electronics.de>


--=-qc5/2QIIQzGbB3R6aIJb
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-10-13 at 18:10 +0900, Akinobu Mita wrote:
> My user space testing exposed off-by-one error find_next_zero_area
> in iommu-helper.

Why not merge those tests into the kernel as a configurable boot-time
self-test?

cheers

--=-qc5/2QIIQzGbB3R6aIJb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkrU9ycACgkQdSjSd0sB4dIXTACgpxW+LkFXep2w0my10iBFI6i2
V8MAoL7CL/p4hU/ZoKeP4Luo4ZBAcbef
=En+T
-----END PGP SIGNATURE-----

--=-qc5/2QIIQzGbB3R6aIJb--

