From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Fri, 28 Apr 2023 13:10:57 +0000
Subject: Re: [PATCH v2 5/5] fbdev: Define framebuffer I/O from Linux' I/O functions
Message-Id: <b9a67217-4665-0d31-378d-ade1d50fe5f1@suse.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------DtzGj0U2BDprAWf4ov3bjWMb"
List-Id: <linux-ia64.vger.kernel.org>
References: <20230428092711.406-1-tzimmermann@suse.de>
 <20230428092711.406-6-tzimmermann@suse.de>
 <430c73f0-45f4-f81e-6506-bc8cc955d936@arm.com>
 <CAMuHMdUGjtiAR37L4_e0_p8ee2=gxoUj7+e7rqMLTBK+vpV4yw@mail.gmail.com>
In-Reply-To: <CAMuHMdUGjtiAR37L4_e0_p8ee2=gxoUj7+e7rqMLTBK+vpV4yw@mail.gmail.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>, Robin Murphy <robin.murphy@arm.com>
Cc: linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, dri-devel@lists.freedesktop.org, James.Bottomley@hansenpartnership.com, sparclinux@vger.kernel.org, kernel@xen0n.name, sam@ravnborg.org, linux-arch@vger.kernel.org, deller@gmx.de, chenhuacai@kernel.org, javierm@redhat.com, vgupta@kernel.org, linux-snps-arc@lists.infradead.org, arnd@arndb.de, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, davem@davemloft.net

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--------------DtzGj0U2BDprAWf4ov3bjWMb
Content-Type: multipart/mixed; boundary="------------QqwzqE2k5QMQXDVM2QKm13co";
 protected-headers="v1"
From: Thomas Zimmermann <tzimmermann@suse.de>
To: Geert Uytterhoeven <geert@linux-m68k.org>,
 Robin Murphy <robin.murphy@arm.com>
Cc: linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org,
 dri-devel@lists.freedesktop.org, James.Bottomley@hansenpartnership.com,
 sparclinux@vger.kernel.org, kernel@xen0n.name, sam@ravnborg.org,
 linux-arch@vger.kernel.org, deller@gmx.de, chenhuacai@kernel.org,
 javierm@redhat.com, vgupta@kernel.org, linux-snps-arc@lists.infradead.org,
 arnd@arndb.de, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev,
 linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org,
 linux-kernel@vger.kernel.org, davem@davemloft.net
Message-ID: <b9a67217-4665-0d31-378d-ade1d50fe5f1@suse.de>
Subject: Re: [PATCH v2 5/5] fbdev: Define framebuffer I/O from Linux' I/O
 functions
References: <20230428092711.406-1-tzimmermann@suse.de>
 <20230428092711.406-6-tzimmermann@suse.de>
 <430c73f0-45f4-f81e-6506-bc8cc955d936@arm.com>
 <CAMuHMdUGjtiAR37L4_e0_p8ee2=gxoUj7+e7rqMLTBK+vpV4yw@mail.gmail.com>
In-Reply-To: <CAMuHMdUGjtiAR37L4_e0_p8ee2=gxoUj7+e7rqMLTBK+vpV4yw@mail.gmail.com>

--------------QqwzqE2k5QMQXDVM2QKm13co
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: base64

SGkNCg0KQW0gMjguMDQuMjMgdW0gMTQ6Mjcgc2NocmllYiBHZWVydCBVeXR0ZXJob2V2ZW46
DQpbLi4uXQ0KPiANCj4gSW4gYWRkaXRpb24sIHRoZSBub24tcmF3IHZhcmlhbnRzIG1heSBk
byBzb21lIGV4dHJhcyB0byBndWFyYW50ZWUNCj4gb3JkZXJpbmcsIHdoaWNoIHlvdSBkbyBu
b3QgbmVlZCBvbiBhIGZyYW1lIGJ1ZmZlci4NCg0KR2l2ZW4gdGhpcyBjb21tZW50LCBzaG91
bGQgd2UgZGVjbGFyZSB0aGUgZmJfKCkgaGVscGVycyBpbiANCjxhc20tZ2VuZXJpYy9pby5o
PiBvciA8bGludXgvaW8uaD4/DQoNCkkgc3RpbGwgZG9uJ3QgbGlrZSB0aGUgaWRlYSBvZiBo
YXZpbmcgdGhlIGZ1bmN0aW9ucyBpbiA8bGludXgvZmIuaD4uIFdlIA0KaGF2ZSBjb2RlIGlu
IERSTSB0aGF0IGFsc28gYWNjZXNzZXMgZnJhbWVidWZmZXIgbWVtb3J5ICh2aWEgDQptZW1j
cHlfdG9pbygpKS4gSXQgd291bGQgbWFrZSBzZW5zZSB0byB1c2UgdGhlIGZiXygpIGhlbHBl
cnMsIGlmIHRoZXkgDQphcmUgdGFpbG9yZWQgdG93YXJkcyB0aGlzIHVzZWNhc2UuDQoNCkJl
c3QgcmVnYXJkcw0KVGhvbWFzDQoNCj4gDQo+IFNvIEknZCBnbyBmb3IgdGhlIF9fcmF3Xyoo
KSB2YXJpYW50cyBldmVyeXdoZXJlLg0KPiANCj4gR3J7b2V0amUsZWV0aW5nfXMsDQo+IA0K
PiAgICAgICAgICAgICAgICAgICAgICAgICAgR2VlcnQNCj4gDQoNCi0tIA0KVGhvbWFzIFpp
bW1lcm1hbm4NCkdyYXBoaWNzIERyaXZlciBEZXZlbG9wZXINClNVU0UgU29mdHdhcmUgU29s
dXRpb25zIEdlcm1hbnkgR21iSA0KRnJhbmtlbnN0cmFzc2UgMTQ2LCA5MDQ2MSBOdWVybmJl
cmcsIEdlcm1hbnkNCkdGOiBJdm8gVG90ZXYsIEFuZHJldyBNeWVycywgQW5kcmV3IE1jRG9u
YWxkLCBCb3VkaWVuIE1vZXJtYW4NCkhSQiAzNjgwOSAoQUcgTnVlcm5iZXJnKQ0K

--------------QqwzqE2k5QMQXDVM2QKm13co--

--------------DtzGj0U2BDprAWf4ov3bjWMb
Content-Type: application/pgp-signature; name="OpenPGP_signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="OpenPGP_signature"

-----BEGIN PGP SIGNATURE-----

wsF5BAABCAAjFiEExndm/fpuMUdwYFFolh/E3EQov+AFAmRLxeEFAwAAAAAACgkQlh/E3EQov+BG
IxAArW6Y0YDQCNr1aySTx/07IbAHS0y+vhIgCiTpfq5oowyVudzNjdBxnedCiRjYWsZfBCjMsdfr
SxG+xgQzdSfWxn5NIwDqE0oEckroWqzuCJYMPzjc8Y1+bJnGiNzVRI12YWtNY0GpaCjcKmUE75ex
6c6loZmjjSiohO5mMQbUKZ2H9VchlqkPVkvuCZb5CdwzMgrMkfcfq9almxX7WdOigfXMpbg2Fk7p
WudCvuFuCIVRRrLIsCowogRjWVN0SL7GwJUN/rHec1FCkBipWrUazGk7oTPG1AXrpOXBSSj6mRCn
H2jj7DsWTgPHaHBBLJelQDwgN3qjA94odDVKgKWGQoncs0+x5pEhkhn1HsOdBNPq6/KpozQPMoGz
QmooLt+AuV98nZyhlHWOxudGcY7/M1ERukgQLYzRVlHeaeQaQb+wbCBkV7Tm8ih99q64LpVwaSS/
Nfv/k/Zfq4yu4mQv24CdUqjlH1aA/XGzlmXlAgEiPpAfAUHgHy3Yoo+tZDtA837yssImYcvhwr2y
0cz3duc61je5Odls9Q9CS1szkJkhFpy9ctg0FrXQbv0IivBLnoxJiK7iES2y0NhXxUK/L9o+L/zc
FEc2JYYMJyNIGFM5dtmBMo6kmUoE5FbGeuwX6Ao4p2q/IoYK7MQ29bcKMRx28VoSCpPON+jpQ95S
M4s=
=GGjv
-----END PGP SIGNATURE-----

--------------DtzGj0U2BDprAWf4ov3bjWMb--
