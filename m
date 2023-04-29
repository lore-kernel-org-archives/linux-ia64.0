From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Sat, 29 Apr 2023 12:28:08 +0000
Subject: Re: [PATCH v2 5/5] fbdev: Define framebuffer I/O from Linux' I/O functions
Message-Id: <b70d5ddb-24ad-e1f5-8ef9-a486879d0c9e@suse.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------5mlU0na0AfM0B8j2RhZVJs01"
List-Id: <linux-ia64.vger.kernel.org>
References: <20230428092711.406-1-tzimmermann@suse.de>
 <20230428092711.406-6-tzimmermann@suse.de>
 <20230428131221.GE3995435@ravnborg.org>
 <900eaf1c-4d29-2c26-c220-6b4e089d9b94@suse.de>
 <20230428165412.GA4010212@ravnborg.org>
In-Reply-To: <20230428165412.GA4010212@ravnborg.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, arnd@arndb.de, deller@gmx.de, chenhuacai@kernel.org, javierm@redhat.com, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, James.Bottomley@hansenpartnership.com, linux-m68k@lists.linux-m68k.org, geert@linux-m68k.org, linux-parisc@vger.kernel.org, vgupta@kernel.org, sparclinux@vger.kernel.org, kernel@xen0n.name, linux-snps-arc@lists.infradead.org, davem@davemloft.net, linux-arm-kernel@lists.infradead.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--------------5mlU0na0AfM0B8j2RhZVJs01
Content-Type: multipart/mixed; boundary="------------f6pmt5OEu3br0LQbMXJxQH0V";
 protected-headers="v1"
From: Thomas Zimmermann <tzimmermann@suse.de>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, arnd@arndb.de,
 deller@gmx.de, chenhuacai@kernel.org, javierm@redhat.com,
 dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org,
 James.Bottomley@hansenpartnership.com, linux-m68k@lists.linux-m68k.org,
 geert@linux-m68k.org, linux-parisc@vger.kernel.org, vgupta@kernel.org,
 sparclinux@vger.kernel.org, kernel@xen0n.name,
 linux-snps-arc@lists.infradead.org, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
Message-ID: <b70d5ddb-24ad-e1f5-8ef9-a486879d0c9e@suse.de>
Subject: Re: [PATCH v2 5/5] fbdev: Define framebuffer I/O from Linux' I/O
 functions
References: <20230428092711.406-1-tzimmermann@suse.de>
 <20230428092711.406-6-tzimmermann@suse.de>
 <20230428131221.GE3995435@ravnborg.org>
 <900eaf1c-4d29-2c26-c220-6b4e089d9b94@suse.de>
 <20230428165412.GA4010212@ravnborg.org>
In-Reply-To: <20230428165412.GA4010212@ravnborg.org>

--------------f6pmt5OEu3br0LQbMXJxQH0V
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: base64

SGkgU2FtDQoNCkFtIDI4LjA0LjIzIHVtIDE4OjU0IHNjaHJpZWIgU2FtIFJhdm5ib3JnOg0K
PiBIaSBUaG9tYXMsDQo+IA0KPiBPbiBGcmksIEFwciAyOCwgMjAyMyBhdCAwNDoxODozOFBN
ICswMjAwLCBUaG9tYXMgWmltbWVybWFubiB3cm90ZToNCj4+IEknZCBiZSBoYXBweSB0byBo
YXZlIGZiXygpIHdyYXBwZXJzIHRoYXQgYXJlIEkvTyBoZWxwZXJzIHdpdGhvdXQNCj4+IG9y
ZGVyaW5nIGd1YXJhbnRlZXMuIEknZCBqdXN0IHdvdWxkbid0IHdhbnQgdGhlbSBpbiA8bGlu
dXgvZmIuaD4NCj4gDQo+IEhvdyBhYm91dCB0aHJvd2luZyB0aGVtIGludG8gYSBuZXcgZHJt
X2ZiLmggaGVhZGVyIGZpbGUuDQo+IFRoaXMgaGVhZGVyIGZpbGUgY291bGQgYmUgdGhlIGhv
bWUgZm9yIGFsbCB0aGUgZmIgc3R1ZmYgdGhhdCBpcw0KPiBzaGFyZWQgYmV0d2VlbiBkcm0g
YW5kIHRoZSBsZWdhY3kgZmJkZXYuDQo+IA0KPiBUaGVuIHdlIG1heSBzbG93bHkgbWlncmF0
ZSBtb3JlIGZiZGV2IHN0dWZmIHRvIGRybSBhbmQgbGV0IHRoZSBsZWdhY3kNCj4gZmJkZXYg
c3R1ZmYgdXNlIHRoZSBtYWludGFpbmVkIGRybSBzdHVmZi4NCj4gRHVubm8sIHRoZSBwYWlu
IG1heSBub3QgYmUgd29ydGggaXQuDQoNCkRSTSBtaWdodCBub3QgYmUgcmVsZXZhbnQgaWYg
d2UgY2FuIHJlbW92ZSBmYl9tZW0qKCkuIFNvIEknZCBsaWtlIHRvIGdvIA0KYmFjayB0byBz
b21ldGhpbmcgY2xvc2VyIHRvIHYxIG9mIHRoZXNlIHBhdGNoZXMuIFNlZSBteSByZXBseSB0
byBBcm5kLg0KDQpCZXN0IHJlZ2FyZHMNClRob21hcw0KDQo+IA0KPiAJU2FtDQoNCi0tIA0K
VGhvbWFzIFppbW1lcm1hbm4NCkdyYXBoaWNzIERyaXZlciBEZXZlbG9wZXINClNVU0UgU29m
dHdhcmUgU29sdXRpb25zIEdlcm1hbnkgR21iSA0KRnJhbmtlbnN0cmFzc2UgMTQ2LCA5MDQ2
MSBOdWVybmJlcmcsIEdlcm1hbnkNCkdGOiBJdm8gVG90ZXYsIEFuZHJldyBNeWVycywgQW5k
cmV3IE1jRG9uYWxkLCBCb3VkaWVuIE1vZXJtYW4NCkhSQiAzNjgwOSAoQUcgTnVlcm5iZXJn
KQ0K

--------------f6pmt5OEu3br0LQbMXJxQH0V--

--------------5mlU0na0AfM0B8j2RhZVJs01
Content-Type: application/pgp-signature; name="OpenPGP_signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="OpenPGP_signature"

-----BEGIN PGP SIGNATURE-----

wsF5BAABCAAjFiEExndm/fpuMUdwYFFolh/E3EQov+AFAmRNDVgFAwAAAAAACgkQlh/E3EQov+Dk
Wg/+JIgc3ljeeweOA51k6nZjVXnA2xoQpHoWXzqgr3zowrr9FFfDh/9evQUoes96v/FyzZlL0CTI
hVueOEwwPmFKXfs1eJ6DBiHNKEwba/mPQXSqkT92eDXl08cADWxMBd9J1rphskh12gJeBQU6U3Qi
5s9GFT3OJJetJ5tLYbqgdkGJntcEFhCOjR2LsoaMIYat474U32GiigcolBwu8aYHhNBij3p2U+LV
JP3bGV9SpX9v2hb6O2daOH4rHdjj+gHXv5+YuoZ9Dqc6XYomdXenX+bgnINpyrcdA0fSFPWRwSJL
yncb89L4GbTNEoiZR9bGBcvTYCj1hIQLASniZvwzHD69fC6i4X1a0Eojn+2WDtWGlSeWplr5Ngn9
r5LAkpkOOvlOMsqV4YJNd8g+QiLDdU4B78fR0CbP6NLjIuuRU83GHKITOwU0GuJBLxu2HKriAmJf
rFPpqks0ZTf8kIqqnLIHiABnGsP+cuYx9gS9l+7T2Lf6vkwPCRtiHaxvBnPuAKSMRvFHulOx+peh
bmKJPoTTkZr1veIxj0ocBwDrOAKbi+ZxE6wKVGTr3GJzr/Y/J40GEy0oUPYTh1csbybKwFdRbDhY
p7IKPw44wVIC0VkGeOU4QBPe8u1Owe8suS15FVeV0h11p9B8Kz6sXcgJr3pGsAl621EIUQF0FKaZ
5Tk=
=1OL4
-----END PGP SIGNATURE-----

--------------5mlU0na0AfM0B8j2RhZVJs01--
