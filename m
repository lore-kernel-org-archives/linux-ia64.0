From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 29 Oct 2008 12:01:21 +0000
Subject: Re: linux-next: Tree for October 28
Message-Id: <1225281681.5439.7.camel@johannes.berg>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-e088Dj2w9G7nGlmS0qHw"
List-Id: <linux-ia64.vger.kernel.org>
References: <20081028183055.fbcf5420.sfr@canb.auug.org.au>
	 <20081028220741.f5d331ba.akpm@linux-foundation.org>
	 (sfid-20081029_060823_839692_3F85A756)
In-Reply-To: <20081028220741.f5d331ba.akpm@linux-foundation.org> (sfid-20081029_060823_839692_3F85A756)
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, linux-wireless@vger.kernel.org, Mark Fasheh <mfasheh@suse.com>, Joel Becker <Joel.Becker@oracle.com>


--=-e088Dj2w9G7nGlmS0qHw
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-10-28 at 22:07 -0700, Andrew Morton wrote:

> and wireless needs some Kconfig help.  Please don't just break other
> architecture's build like this.
>=20
> drivers/staging/wlan-ng/wlan_compat.h:136:3: #error "No CPU identified!"
> drivers/staging/wlan-ng/wlan_compat.h:695:6: warning: "WLAN_CPU_FAMILY" i=
s not defined
> drivers/staging/wlan-ng/wlan_compat.h:699:6: warning: "WLAN_CPU_FAMILY" i=
s not defined

This isn't wireless, it's staging. Talk to Greg, not to linux-wireless.

johannes

--=-e088Dj2w9G7nGlmS0qHw
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJCFCNAAoJEKVg1VMiehFYFIkP/0YGJO/fu/libSPrwysAyYt6
O7RS96vjcjqEdde7OzwLQuJar75KdTe2XWg2CVv/SgNlFZRwGVKwqcZ1Yc08b7EW
SNatkJdsZ08tkmdRIzb2UZ+91efB8+Id+vOV/H4pRxLghznB7QII7z94QwUq9JAi
XkPGMvMNXq5jjv8dZNZNtFXTTyVnPNuLQLcMZli6GWVBUHEpguJxz7N+oLDU/wz1
rs7HQOQ3bWv2NxgRUKJZUaF6NWzWpCy3pqazxDmR1yTq9kewrjGB/akDYzJjt9p/
fTXl5AVYVLhrppxL4aQhWZYdMYYOagxM3/m5QTf63ivllBa+R4wsse4UPU+qdVlN
o7sIZZhV0AaMDQOx6SzNgxj0Yh1ruSrWlH1DBHbVzHaAsT7IvgEe9zAOrcPNmitS
9AJQtqhM17gfxXuaFFtO9Q3+WJ5Bz4njwh7RfxQsNgulp95T7DsQtIfPghe7vBmG
l4VaQZbVw4d9n+6akB0sdz0bS4YOZWRI5TAZMCbrNyQV1mUJEuIvd+b3k6ANo+i6
3K2FJk3VF8+yb6gC5PkfliRgc45Q5g4qLjqy36vJAi5/8cKPEQn3Ke1BDxUpUhF9
sl7m7hfU3P+WXMxrqwQMkJ2Qx4BVHNnvzWhM3PnNltnx2aZGcPtRZpuecrCa0Ytx
olvxtw+c2oLCtwOv3EVh
=JjNC
-----END PGP SIGNATURE-----

--=-e088Dj2w9G7nGlmS0qHw--

