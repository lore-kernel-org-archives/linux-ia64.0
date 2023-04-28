From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Fri, 28 Apr 2023 13:13:14 +0000
Subject: Re: [PATCH v2 4/5] fbdev: Include <linux/io.h> in drivers
Message-Id: <9f1a0333-2b38-aff8-b7ec-1e7e2d6f203e@suse.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------K8mbcyK73ItkXrLpqFqbRMJT"
List-Id: <linux-ia64.vger.kernel.org>
References: <20230428092711.406-1-tzimmermann@suse.de>
 <20230428092711.406-5-tzimmermann@suse.de>
 <20230428130702.GD3995435@ravnborg.org>
In-Reply-To: <20230428130702.GD3995435@ravnborg.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--------------K8mbcyK73ItkXrLpqFqbRMJT
Content-Type: multipart/mixed; boundary="------------i1vI92Qck051EDO3TuJJL9FR";
 protected-headers="v1"
From: Thomas Zimmermann <tzimmermann@suse.de>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch,
 vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name,
 davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de,
 linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
 loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org,
 sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-parisc@vger.kernel.org
Message-ID: <9f1a0333-2b38-aff8-b7ec-1e7e2d6f203e@suse.de>
Subject: Re: [PATCH v2 4/5] fbdev: Include <linux/io.h> in drivers
References: <20230428092711.406-1-tzimmermann@suse.de>
 <20230428092711.406-5-tzimmermann@suse.de>
 <20230428130702.GD3995435@ravnborg.org>
In-Reply-To: <20230428130702.GD3995435@ravnborg.org>

--------------i1vI92Qck051EDO3TuJJL9FR
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: base64

SGkgU2FtDQoNCkFtIDI4LjA0LjIzIHVtIDE1OjA3IHNjaHJpZWIgU2FtIFJhdm5ib3JnOg0K
PiBPbiBGcmksIEFwciAyOCwgMjAyMyBhdCAxMToyNzoxMEFNICswMjAwLCBUaG9tYXMgWmlt
bWVybWFubiB3cm90ZToNCj4+IEZiZGV2J3MgbWFpbiBoZWFkZXIgZmlsZSwgPGxpbnV4L2Zi
Lmg+LCBpbmNsdWRlcyA8YXNtL2lvLmg+IHRvIGdldA0KPj4gZGVjbGFyYXRpb25zIG9mIEkv
TyBoZWxwZXIgZnVuY3Rpb25zLiBGcm9tIHRoZXNlIGRlY2xhcmF0b25zLCBpdCBsYXRlcg0K
Pj4gZGVmaW5lcyBmcmFtZWJ1ZmZlciBJL08gaGVscGVycywgc3VjaCBhcyBmYl97cmVhZCx3
cml0ZX1bYndscV0oKSBvcg0KPj4gZmJfbWVtc2V0KCkuDQo+Pg0KPj4gVGhlIGZyYW1lYnVm
ZmVyIEkvTyBoZWxwZXJzIHByZS1kYXRlIExpbnV4JyBjdXJyZW50IEkvTyBjb2RlIGFuZCB3
aWxsDQo+PiBiZSByZXBsYWNlZCBieSByZWd1bGFyIEkvTyBoZWxwZXJzLiBQcmVwYXJlIHRo
aXMgY2hhbmdlIGJ5IGFkZGluZyBhbg0KPj4gaW5jbHVkZSBzdGF0ZW1lbnQgZm9yIDxsaW51
eC9pby5oPiB0byBhbGwgc291cmNlIGZpbGVzIHRoYXQgdXNlIHRoZQ0KPj4gZnJhbWVidWZm
ZXIgSS9PIGhlbHBlcnMuIFRoZXkgd2lsbCBzdGlsbCBnZXQgZGVjbGFyYXRpb25zIG9mIHRo
ZSBJL08NCj4+IGZ1bmN0aW9ucyBldmVuIGFmdGVyIDxsaW51eC9mYi5oPiBoYXMgYmVlbiBj
bGVhbmVkIHVwLg0KPiBXaGVuIGZiLmggdXNlcyBhIHN5bWJvbCBmcm9tIGlvLmgsIHRoZW4g
aXQgc2hhbGwgaW5jbHVkZSB0aGF0DQo+IGZpbGUgc28gaXQgaXMgc2VsZiBjb250YWluZWQu
DQo+IFNvIGl0IGlzIHdyb25nIHRvIHB1c2ggdGhlIGlvLmggaW5jbHVkZSB0byB0aGUgdXNl
cnMgb2YNCj4gZmJfe3JlYWQsd3JpdGUseHh4fS4gTWF5YmUgZmIuaCBvbmx5IHVzZXMgbWFj
cm9zIGFzIGlzIHRoZSBjYXNlIGhlcmUsDQo+IGJ1dCB0aGF0IGlzIG5vIGV4Y3VzZSBudCB0
byBpbmNsdWRlIGlvLmguDQo+IA0KPiBEcm9wIHRoZXNlIGNoYW5nZXMuDQoNCk5vIHByb2Js
ZW0uIFRoYXQgd2FzIGRvbmUgd2l0aCBhbiBleWUgb24gcmVtb3ZpbmcgdGhlIGZiXygpIG1h
Y3JvcyANCmVudGlyZWx5LiBCdXQgdGhlIGRpc2N1c3Npb24gYXJvdW5kIHBhdGNoIDUgbm93
IGdvZXMgaW4gYSBkaWZmZXJlbnQgDQpkaXJlY3Rpb24gYW55d2F5Lg0KDQpCZXN0IHJlZ2Fy
ZHMNClRob21hcw0KDQo+IA0KPj4gRHJpdmVyIHNvdXJjZQ0KPj4gZmlsZXMgdGhhdCBhbHJl
YWR5IGluY2x1ZGUgPGFzbS9pby5oPiBjb252ZXJ0IHRvIDxsaW51eC9pby5oPi4NCj4gVGhp
cyBpcyBhIG5pY2UgY2xlYW51cCAtIHdlIHNob3VsZCBrZWVwIHRoYXQuDQo+IA0KPiAJU2Ft
DQoNCi0tIA0KVGhvbWFzIFppbW1lcm1hbm4NCkdyYXBoaWNzIERyaXZlciBEZXZlbG9wZXIN
ClNVU0UgU29mdHdhcmUgU29sdXRpb25zIEdlcm1hbnkgR21iSA0KRnJhbmtlbnN0cmFzc2Ug
MTQ2LCA5MDQ2MSBOdWVybmJlcmcsIEdlcm1hbnkNCkdGOiBJdm8gVG90ZXYsIEFuZHJldyBN
eWVycywgQW5kcmV3IE1jRG9uYWxkLCBCb3VkaWVuIE1vZXJtYW4NCkhSQiAzNjgwOSAoQUcg
TnVlcm5iZXJnKQ0K

--------------i1vI92Qck051EDO3TuJJL9FR--

--------------K8mbcyK73ItkXrLpqFqbRMJT
Content-Type: application/pgp-signature; name="OpenPGP_signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="OpenPGP_signature"

-----BEGIN PGP SIGNATURE-----

wsF5BAABCAAjFiEExndm/fpuMUdwYFFolh/E3EQov+AFAmRLxmoFAwAAAAAACgkQlh/E3EQov+DB
Sw/+NzBofbtWHCiUo4qze7+jqvl3Bn2uyszgcZ5nOK6vBK0eS2lwMGrF01oypgJ05zObhEw7BBa9
X7OOQCAHaFPD/XiVW499dO3sbBsRxPNbvmmMWGBiw6yMT3leovksVwilyAKTPsL0RO2zzbJQeP1l
8qijSwJDN1yj8XiIPWcCHOo0bP6Xn5Af0e5JewAO5g6tdUZj7t8XspfkAHx6TIfPfBgScDLBQVnG
5dbEod1W2eDXywIKj5fxpxGd3OWia7UC7YB5qnQ/1RwNa9ts6yNKxpj8OKQKXfGLS9mlTCyR4K86
5w4vSBY2pNLeI6ph2v5v+XN9WcNTVobqlUeO8tJMKUeWiB8ryGNbBn1Kn2US8wrN+vvGm7rkPMCf
VzJxBA8mschlpuzPug67pdt4SVObAol7m3dAcL4oSQgsvyyLw2Vzy5+T0a7ebl1BgXIZy4GdF+QA
mka8caTny5EYRuWO20U7S/ZXIoxZPJGLqiw+GMn68XZ9512d0eGsPZoHM+KxqPqiJxeHgqS5tmxh
P+EFlxSmUhBFG2r0+X/SjHYkTgB5Zj6bE4BHtGRAW7RtuIQ7d1F1aKcckYQ09RQZ4WdcViJscC57
hqLPSWJ2koOE0FI0wx7BLmkNGroVVfc3cWpue5dUVeFnwz5+iarvnDTywVTxMa5vRnntE0Hj4yiu
Q8w=
=drwU
-----END PGP SIGNATURE-----

--------------K8mbcyK73ItkXrLpqFqbRMJT--
