From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Mon, 17 Apr 2023 09:04:39 +0000
Subject: Re: [PATCH v2 02/19] arch/arc: Implement <asm/fb.h> with generic helpers
Message-Id: <4450d4bf-a6e0-764e-d1c4-efba272f0529@suse.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------iPEL9xuP1J0A8seUIdWajJMz"
List-Id: <linux-ia64.vger.kernel.org>
References: <20230406143019.6709-1-tzimmermann@suse.de>
 <20230406143019.6709-3-tzimmermann@suse.de>
 <27c1210f-4e40-4bbc-905b-155427465e00@app.fastmail.com>
In-Reply-To: <27c1210f-4e40-4bbc-905b-155427465e00@app.fastmail.com>
To: Arnd Bergmann <arnd@arndb.de>, Daniel Vetter <daniel.vetter@ffwll.ch>, Helge Deller <deller@gmx.de>, Javier Martinez Canillas <javierm@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Linux-Arch <linux-arch@vger.kernel.org>, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, Vineet Gupta <vgupta@kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--------------iPEL9xuP1J0A8seUIdWajJMz
Content-Type: multipart/mixed; boundary="------------ITCxEOG7I6GWaznxs8pYlTkW";
 protected-headers="v1"
From: Thomas Zimmermann <tzimmermann@suse.de>
To: Arnd Bergmann <arnd@arndb.de>, Daniel Vetter <daniel.vetter@ffwll.ch>,
 Helge Deller <deller@gmx.de>, Javier Martinez Canillas <javierm@redhat.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Linux-Arch <linux-arch@vger.kernel.org>, linux-fbdev@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-ia64@vger.kernel.org, loongarch@lists.linux.dev,
 linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org,
 linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Vineet Gupta <vgupta@kernel.org>
Message-ID: <4450d4bf-a6e0-764e-d1c4-efba272f0529@suse.de>
Subject: Re: [PATCH v2 02/19] arch/arc: Implement <asm/fb.h> with generic
 helpers
References: <20230406143019.6709-1-tzimmermann@suse.de>
 <20230406143019.6709-3-tzimmermann@suse.de>
 <27c1210f-4e40-4bbc-905b-155427465e00@app.fastmail.com>
In-Reply-To: <27c1210f-4e40-4bbc-905b-155427465e00@app.fastmail.com>

--------------ITCxEOG7I6GWaznxs8pYlTkW
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: base64

DQoNCkFtIDA2LjA0LjIzIHVtIDE2OjQzIHNjaHJpZWIgQXJuZCBCZXJnbWFubjoNCj4gT24g
VGh1LCBBcHIgNiwgMjAyMywgYXQgMTY6MzAsIFRob21hcyBaaW1tZXJtYW5uIHdyb3RlOg0K
Pj4gKw0KPj4gICBzdGF0aWMgaW5saW5lIHZvaWQgZmJfcGdwcm90ZWN0KHN0cnVjdCBmaWxl
ICpmaWxlLCBzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSwNCj4+ICAgCQkJCXVuc2lnbmVk
IGxvbmcgb2ZmKQ0KPj4gICB7DQo+PiAgIAl2bWEtPnZtX3BhZ2VfcHJvdCA9IHBncHJvdF9u
b25jYWNoZWQodm1hLT52bV9wYWdlX3Byb3QpOw0KPj4gICB9DQo+PiArI2RlZmluZSBmYl9w
Z3Byb3RlY3QgZmJfcGdwcm90ZWN0DQo+IA0KPiBJIHN0aWxsIGZlZWwgdGhhdCBmb3IgYXJj
aGl0ZWN0dXJlcyBsaWtlIGFyYyB0aGF0IGRvbid0IGhhdmUNCj4gcGdwcm90X3dyaXRlY29t
YmluZSgpLCBpdCB3b3VsZCBiIGJlc3QgdG8gZ28gd2l0aCB0aGUNCj4gZ2VuZXJpYyBpbXBs
ZW1lbnRhdGlvbiB0aGF0IGN1cnJlbnRseSBiZWhhdmVzIHRoZSBleGFjdA0KPiBzYW1lIHdh
eS4gSWYgcGdwcm90X3dyaXRlY29tYmluZSgpIGdldHMgYWRkZWQgaW4gdGhlIGZ1dHVyZSwN
Cj4gaXQgd291bGQgY2F1c2UgdGhlIGFyY2hpdGVjdHVyZSB0byBiZWhhdmUgYXMgZXhwZWN0
ZWQgcmF0aGVyDQo+IHRoYW4gaW50cm9kdWNpbmcgdGhlIHNhbWUgYnVnIHRoYXQgbWlwcyBo
YXMuDQoNCk9LLCBJJ2xsIGNoYW5nZSBpdC4NCg0KPiANCj4gICAgICAgIEFybmQNCg0KLS0g
DQpUaG9tYXMgWmltbWVybWFubg0KR3JhcGhpY3MgRHJpdmVyIERldmVsb3Blcg0KU1VTRSBT
b2Z0d2FyZSBTb2x1dGlvbnMgR2VybWFueSBHbWJIDQpNYXhmZWxkc3RyLiA1LCA5MDQwOSBO
w7xybmJlcmcsIEdlcm1hbnkNCihIUkIgMzY4MDksIEFHIE7DvHJuYmVyZykNCkdlc2Now6Rm
dHNmw7xocmVyOiBJdm8gVG90ZXYNCg==

--------------ITCxEOG7I6GWaznxs8pYlTkW--

--------------iPEL9xuP1J0A8seUIdWajJMz
Content-Type: application/pgp-signature; name="OpenPGP_signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="OpenPGP_signature"

-----BEGIN PGP SIGNATURE-----

wsF5BAABCAAjFiEExndm/fpuMUdwYFFolh/E3EQov+AFAmQ9C6cFAwAAAAAACgkQlh/E3EQov+Ac
QBAAsfmjop5GpI2/M6n6MvSHBTqHHtmA95cabDcKwQFUOYGC55wDQtKCk1YbTbOeOOp4DHs0Rob4
xWSoykdeIUiYGbc8U+MPXGhCdo2C2sKIZkY1wgmuti3n3EkfC6k6Cx9aCz+tiJ+jd9E45wBaOnaE
56XOzZWvxMz+zYzMPsC0pDMXkpZW1XtmvqXrjF6Ohri8O/In5if4HwkiXyJhY0aEXDHB5qLJU+SI
b+YsRcUJLtzaBG/4xUkrhyP1kpTB/tNLYF4Z9fw7YtOUj+DXACQArqlHD8tVe+Z8HfxPmhRId6bp
XouIgS+7VDb0Utb5Nd22dACIzY1DC6CXiz04MI8o++SCFEAK/FZedYlrXtkriEEYX2pcvlUbU+1p
1RB16i/tjmLBhntUmgiUCOQZxk1IIcpOn13HiEGxkin8oFdsKztsrpK15yCcuTY0/1vlx/bahdFv
Mtsy0ss6D9F1XmgpgRJjQkxR1KNV6LNvXzC56bQdk1qiPg6hRRIh5V65ygR1nowW8PHA3kZw5aS0
tGeYxjnvqz41zAoXzDM3bDKjPcdgFfuzm25s3Z3nwqLsD8nKpoSR6Jr+IpXKNxikB8yx3b9GCTbe
C/MTua22YAkNdKZ2MS00YzB8dMZ0u2ZCINsYOTcIYIN+s8mpb7LPO7Zj36RDWZCJMILkijh/NUmM
Xe0=
=9BHz
-----END PGP SIGNATURE-----

--------------iPEL9xuP1J0A8seUIdWajJMz--
