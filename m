From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Fri, 05 May 2023 07:02:50 +0000
Subject: Re: [PATCH v4 4/6] fbdev: Include <linux/fb.h> instead of <asm/fb.h>
Message-Id: <54679884-9307-f828-dca4-34cb781dc463@suse.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------OVNAYynKUsk0MtSxKZ0ZybeJ"
List-Id: <linux-ia64.vger.kernel.org>
References: <20230504074539.8181-1-tzimmermann@suse.de>
 <20230504074539.8181-5-tzimmermann@suse.de>
 <20230504153710.GA518522@ravnborg.org>
In-Reply-To: <20230504153710.GA518522@ravnborg.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, arnd@arndb.de, deller@gmx.de, chenhuacai@kernel.org, javierm@redhat.com, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, James.Bottomley@hansenpartnership.com, linux-m68k@lists.linux-m68k.org, geert@linux-m68k.org, linux-parisc@vger.kernel.org, vgupta@kernel.org, sparclinux@vger.kernel.org, kernel@xen0n.name, linux-snps-arc@lists.infradead.org, davem@davemloft.net, linux-arm-kernel@lists.infradead.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--------------OVNAYynKUsk0MtSxKZ0ZybeJ
Content-Type: multipart/mixed; boundary="------------w56d0we4Beh0uPurMRS337ha";
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
Message-ID: <54679884-9307-f828-dca4-34cb781dc463@suse.de>
Subject: Re: [PATCH v4 4/6] fbdev: Include <linux/fb.h> instead of <asm/fb.h>
References: <20230504074539.8181-1-tzimmermann@suse.de>
 <20230504074539.8181-5-tzimmermann@suse.de>
 <20230504153710.GA518522@ravnborg.org>
In-Reply-To: <20230504153710.GA518522@ravnborg.org>

--------------w56d0we4Beh0uPurMRS337ha
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: base64

SGkNCg0KQW0gMDQuMDUuMjMgdW0gMTc6Mzcgc2NocmllYiBTYW0gUmF2bmJvcmc6DQo+IEhp
IFRob21hcywNCj4gDQo+IE9uIFRodSwgTWF5IDA0LCAyMDIzIGF0IDA5OjQ1OjM3QU0gKzAy
MDAsIFRob21hcyBaaW1tZXJtYW5uIHdyb3RlOg0KPj4gUmVwbGFjZSBpbmNsdWRlIHN0YXRl
bWVudHMgZm9yIDxhc20vZmIuaD4gd2l0aCA8bGludXgvZmIuaD4uIEZpeGVzDQo+PiB0aGUg
Y29kaW5nIHN0eWxlOiBpZiBhIGhlYWRlciBpcyBhdmFpbGFibGUgaW4gYXNtLyBhbmQgbGlu
dXgvLCBpdA0KPj4gaXMgcHJlZmVyYWJsZSB0byBpbmNsdWRlIHRoZSBoZWFkZXIgZnJvbSBs
aW51eC8uIFRoaXMgb25seSBhZmZlY3RzDQo+PiBhIGZldyBzb3VyY2UgZmlsZXMsIG1vc3Qg
b2Ygd2hpY2ggYWxyZWFkeSBpbmNsdWRlIDxsaW51eC9mYi5oPi4NCj4+DQo+PiBTdWdnZXN0
ZWQtYnk6IFNhbSBSYXZuYm9yZyA8c2FtQHJhdm5ib3JnLm9yZz4NCj4+IFNpZ25lZC1vZmYt
Ynk6IFRob21hcyBaaW1tZXJtYW5uIDx0emltbWVybWFubkBzdXNlLmRlPg0KPiANCj4gVGhh
bmtzLA0KPiBSZXZpZXdlZC1ieTogU2FtIFJhdm5ib3JnIDxzYW1AcmF2bmJvcmcub3JnPg0K
DQpUaGFua3MgZm9yIHJldmlld2luZy4gSSBpbnRlbnQgdG8gbWVyZ2UgdGhpcyBlYXJseSBu
ZXh0IHdlZWsgYWZ0ZXIgdGhlIA0KdXBjb21pbmcgLXJjMSBoYXMgbGFuZGVkIGluIHRoZSBE
Uk0gbWlzYyB0cmVlcy4NCg0KQmVzdCByZWdhcmRzDQpUaG9tYXMNCg0KLS0gDQpUaG9tYXMg
WmltbWVybWFubg0KR3JhcGhpY3MgRHJpdmVyIERldmVsb3Blcg0KU1VTRSBTb2Z0d2FyZSBT
b2x1dGlvbnMgR2VybWFueSBHbWJIDQpGcmFua2Vuc3RyYXNzZSAxNDYsIDkwNDYxIE51ZXJu
YmVyZywgR2VybWFueQ0KR0Y6IEl2byBUb3RldiwgQW5kcmV3IE15ZXJzLCBBbmRyZXcgTWNE
b25hbGQsIEJvdWRpZW4gTW9lcm1hbg0KSFJCIDM2ODA5IChBRyBOdWVybmJlcmcpDQo=

--------------w56d0we4Beh0uPurMRS337ha--

--------------OVNAYynKUsk0MtSxKZ0ZybeJ
Content-Type: application/pgp-signature; name="OpenPGP_signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="OpenPGP_signature"

-----BEGIN PGP SIGNATURE-----

wsF5BAABCAAjFiEExndm/fpuMUdwYFFolh/E3EQov+AFAmRUqhoFAwAAAAAACgkQlh/E3EQov+BS
ExAAk6joIh9cdDj+QXWNzSZK8ZvX7kdroXQJShSXL0qeH/0/Enm5utlSP6lnNpxO8utZSygCPx49
5is8IZ12TOOMwPuoe7jmbepPlRg9oI33B/ch5GRPT6JBRu4YkQgnMrI2xD8m/ENCIRkDcQsXl5b8
xzdrSxUySEZxtFHABCXVVNffMqzDpeC7FdfplfsCtPKk2DS3XxAOEw6hvG9f6zdasELsMFGL+5wO
yYdOKyV7FPkZoHmMXxLdAgUjDd0oLshyzmDnPcPSQbrdsdh9Sj/jJpUAPHtohndBXzCHd+69zNIV
s0Z5ScYl03jlO1Tue7ggA9GDMb6vTEG7mmc70m1bROeLrzxjChbzEJFqDZKxPKPrCRtIeRTWgIcM
HdEX9R75aaLlikt+eAyc2eL4LRUPKOMDmJqiPp7r/RzLbFbxcDLjeTkzBvWOBM4OWfI+5K9ad/xL
L7/vFBoXsfGl96dULvEzu5wPX9KESYeEu4u5hby2jwtN5FpUH5JewvTkdZNjk35Ad0awpDC2qt4h
aZtYGMplwRguhc06s7GEAehycRuhld/IQdlOEQgOEoM8OT8qSnVKj+uBEG6Hkzda0eEGY+xlzUTA
Dh7H8V6PqhvFIj1FA+DRzw/XE9xWO0uBFv/mLu5DWE7hRph1xfBkDPExqayoPjQqBXRVoFAx+ZSe
QdM=
=z1Er
-----END PGP SIGNATURE-----

--------------OVNAYynKUsk0MtSxKZ0ZybeJ--
