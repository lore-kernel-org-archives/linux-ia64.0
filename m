From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Wed, 10 May 2023 14:27:10 +0000
Subject: Re: [PATCH v6 5/6] fbdev: Move framebuffer I/O helpers into <asm/fb.h>
Message-Id: <49684d58-c19d-b147-5e9f-2ac526dd50f0@suse.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------0lOLE90wJNsb39RLAMUItepY"
List-Id: <linux-ia64.vger.kernel.org>
References: <20230510110557.14343-6-tzimmermann@suse.de>
 <202305102136.eMjTSPwH-lkp@intel.com>
 <f6b2d541-d235-4e98-afcc-9137fb8afa35@app.fastmail.com>
In-Reply-To: <f6b2d541-d235-4e98-afcc-9137fb8afa35@app.fastmail.com>
To: Arnd Bergmann <arnd@arndb.de>, kernel test robot <lkp@intel.com>, Helge Deller <deller@gmx.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Javier Martinez Canillas <javierm@redhat.com>, Daniel Vetter <daniel@ffwll.ch>, Vineet Gupta <vgupta@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, "David S . Miller" <davem@davemloft.net>, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, Sam Ravnborg <sam@ravnborg.org>, suijingfeng@loongson.cn
Cc: oe-kbuild-all@lists.linux.dev, Linux-Arch <linux-arch@vger.kernel.org>, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, sparclinux@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--------------0lOLE90wJNsb39RLAMUItepY
Content-Type: multipart/mixed; boundary="------------QVvnIHXNHplIvwXCWF9C7D0M";
 protected-headers="v1"
From: Thomas Zimmermann <tzimmermann@suse.de>
To: Arnd Bergmann <arnd@arndb.de>, kernel test robot <lkp@intel.com>,
 Helge Deller <deller@gmx.de>, Geert Uytterhoeven <geert@linux-m68k.org>,
 Javier Martinez Canillas <javierm@redhat.com>,
 Daniel Vetter <daniel@ffwll.ch>, Vineet Gupta <vgupta@kernel.org>,
 Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>,
 "David S . Miller" <davem@davemloft.net>,
 "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>,
 Sam Ravnborg <sam@ravnborg.org>, suijingfeng@loongson.cn
Cc: oe-kbuild-all@lists.linux.dev, Linux-Arch <linux-arch@vger.kernel.org>,
 linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org,
 linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-m68k@lists.linux-m68k.org,
 loongarch@lists.linux.dev, sparclinux@vger.kernel.org,
 linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org
Message-ID: <49684d58-c19d-b147-5e9f-2ac526dd50f0@suse.de>
Subject: Re: [PATCH v6 5/6] fbdev: Move framebuffer I/O helpers into
 <asm/fb.h>
References: <20230510110557.14343-6-tzimmermann@suse.de>
 <202305102136.eMjTSPwH-lkp@intel.com>
 <f6b2d541-d235-4e98-afcc-9137fb8afa35@app.fastmail.com>
In-Reply-To: <f6b2d541-d235-4e98-afcc-9137fb8afa35@app.fastmail.com>

--------------QVvnIHXNHplIvwXCWF9C7D0M
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: base64

SGkNCg0KQW0gMTAuMDUuMjMgdW0gMTY6MTUgc2NocmllYiBBcm5kIEJlcmdtYW5uOg0KPiBP
biBXZWQsIE1heSAxMCwgMjAyMywgYXQgMTY6MDMsIGtlcm5lbCB0ZXN0IHJvYm90IHdyb3Rl
Og0KPiANCj4+DQo+PiAgICAgY2MxOiB3YXJuaW5nOiBhcmNoL3NoL2luY2x1ZGUvbWFjaC1o
cDZ4eDogTm8gc3VjaCBmaWxlIG9yIGRpcmVjdG9yeQ0KPj4gWy1XbWlzc2luZy1pbmNsdWRl
LWRpcnNdDQo+PiAgICAgY2MxOiB3YXJuaW5nOiBhcmNoL3NoL2luY2x1ZGUvbWFjaC1ocDZ4
eDogTm8gc3VjaCBmaWxlIG9yIGRpcmVjdG9yeQ0KPj4gWy1XbWlzc2luZy1pbmNsdWRlLWRp
cnNdDQo+PiAgICAgSW4gZmlsZSBpbmNsdWRlZCBmcm9tIGRyaXZlcnMvdmlkZW8vZmJkZXYv
aGl0ZmIuYzoyNzoNCj4+ICAgICBkcml2ZXJzL3ZpZGVvL2ZiZGV2L2hpdGZiLmM6IEluIGZ1
bmN0aW9uICdoaXRmYl9hY2NlbF93YWl0JzoNCj4+Pj4gYXJjaC9zaC9pbmNsdWRlL2FzbS9o
ZDY0NDYxLmg6MTg6MzM6IHdhcm5pbmc6IHBhc3NpbmcgYXJndW1lbnQgMSBvZiAnZmJfcmVh
ZHcnIG1ha2VzIHBvaW50ZXIgZnJvbSBpbnRlZ2VyIHdpdGhvdXQgYSBjYXN0IFstV2ludC1j
b252ZXJzaW9uXQ0KPj4gICAgICAgIDE4IHwgI2RlZmluZSBIRDY0NDYxX0lPX09GRlNFVCh4
KSAgICAoSEQ2NDQ2MV9JT0JBU0UgKyAoeCkpDQo+PiAgICAgICAgICAgfCAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgIF5+fn5+fn5+fn5+fn5+fn5+fn5+fn4NCj4+ICAgICAg
ICAgICB8ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfA0KPj4gICAgICAgICAg
IHwgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB1bnNpZ25lZCBpbnQNCj4+ICAg
ICBhcmNoL3NoL2luY2x1ZGUvYXNtL2hkNjQ0NjEuaDo5MzozMzogbm90ZTogaW4gZXhwYW5z
aW9uIG9mIG1hY3JvDQo+PiAnSEQ2NDQ2MV9JT19PRkZTRVQnDQo+PiAgICAgICAgOTMgfCAj
ZGVmaW5lIEhENjQ0NjFfR1JDRkdSICAgICAgICAgIEhENjQ0NjFfSU9fT0ZGU0VUKDB4MTA0
NCkNCj4+ICAgICAvKiBBY2NlbGVyYXRvciBDb25maWd1cmF0aW9uIFJlZ2lzdGVyICovDQo+
PiAgICAgICAgICAgfCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIF5+fn5+fn5+
fn5+fn5+fn5+DQo+PiAgICAgZHJpdmVycy92aWRlby9mYmRldi9oaXRmYi5jOjQ3OjI1OiBu
b3RlOiBpbiBleHBhbnNpb24gb2YgbWFjcm8NCj4+ICdIRDY0NDYxX0dSQ0ZHUicNCj4+ICAg
ICAgICA0NyB8ICAgICAgICAgd2hpbGUgKGZiX3JlYWR3KEhENjQ0NjFfR1JDRkdSKSAmDQo+
PiBIRDY0NDYxX0dSQ0ZHUl9BQ0NTVEFUVVMpIDsNCj4gDQo+IEkgdGhpbmsgdGhhdCdzIGEg
cHJlZXhpc3RpbmcgYnVnIGFuZCBJIGhhdmUgbm8gaWRlYSB3aGF0IHRoZQ0KPiBjb3JyZWN0
IHNvbHV0aW9uIGlzLiBMb29raW5nIGZvciBIRDY0NDYxIHNob3dzIGl0IGJlaW5nIHVzZWQN
Cj4gYm90aCB3aXRoIGludy9vdXR3IGFuZCByZWFkdy93cml0ZXcsIHNvIHRoZXJlIGlzIG5v
IHdheSB0byBoYXZlDQo+IHRoZSBjb3JyZWN0IHR5cGUuIFRoZSBzaCBfX3Jhd19yZWFkdygp
IGRlZmluaXRpb24gaGlkZXMgdGhpcyBidWcsDQo+IGJ1dCB0aGF0IGlzIGEgcHJvYmxlbSB3
aXRoIGFyY2gvc2ggYW5kIGl0IHByb2JhYmx5IGhpZGVzIG90aGVycw0KPiBhcyB3ZWxsLg0K
DQpUaGUgY29uc3RhbnQgSEQ2NDQ2MV9JT0JBU0UgaXMgZGVmaW5lZCBhcyBpbnRlZ2VyIGF0
DQoNCiANCmh0dHBzOi8vZWxpeGlyLmJvb3RsaW4uY29tL2xpbnV4L2xhdGVzdC9zb3VyY2Uv
YXJjaC9zaC9pbmNsdWRlL2FzbS9oZDY0NDYxLmgjTDE3DQoNCmJ1dCBmYl9yZWFkdygpIGV4
cGVjdHMgYSB2b2xhdGlsZS12b2lkIHBvaW50ZXIuIEkgZ3Vlc3Mgd2UgY291bGQgYWRkIGEg
DQpjYXN0IHNvbWV3aGVyZSB0byBzaWxlbmNlIHRoZSBwcm9ibGVtLiBJbiB0aGUgY3VycmVu
dCB1cHN0cmVhbSBjb2RlLCANCnRoYXQgYXBwZWFycyB0byBiZSBkb25lIGJ5IHNoJ3MgX19y
YXdfcmVhZHcoKSBpbnRlcm5hbGx5Og0KDQogDQpodHRwczovL2VsaXhpci5ib290bGluLmNv
bS9saW51eC9sYXRlc3Qvc291cmNlL2FyY2gvc2gvaW5jbHVkZS9hc20vaW8uaCNMMzUNCg0K
QmVzdCByZWdhcmRzDQpUaG9tYXMNCg0KPiANCj4gICAgICAgICBBcm5kDQoNCi0tIA0KVGhv
bWFzIFppbW1lcm1hbm4NCkdyYXBoaWNzIERyaXZlciBEZXZlbG9wZXINClNVU0UgU29mdHdh
cmUgU29sdXRpb25zIEdlcm1hbnkgR21iSA0KRnJhbmtlbnN0cmFzc2UgMTQ2LCA5MDQ2MSBO
dWVybmJlcmcsIEdlcm1hbnkNCkdGOiBJdm8gVG90ZXYsIEFuZHJldyBNeWVycywgQW5kcmV3
IE1jRG9uYWxkLCBCb3VkaWVuIE1vZXJtYW4NCkhSQiAzNjgwOSAoQUcgTnVlcm5iZXJnKQ0K


--------------QVvnIHXNHplIvwXCWF9C7D0M--

--------------0lOLE90wJNsb39RLAMUItepY
Content-Type: application/pgp-signature; name="OpenPGP_signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="OpenPGP_signature"

-----BEGIN PGP SIGNATURE-----

wsF5BAABCAAjFiEExndm/fpuMUdwYFFolh/E3EQov+AFAmRbqb4FAwAAAAAACgkQlh/E3EQov+D5
XA/+NTq2UPDUmKMuT09nX2chx123JIho9zlMm9ERbRkgZCKs3jMkaQBIC+gjppyyC1kloaztXcvL
VF1riaHZAXzrc6jtJ6U13uytRYq5fO2qwltWxGsB9Er81Qq1YBCxdbFdb4avEiL8PQkfPdan18iV
iKLAAkkJVL9RZQmZ62DjZT8XtqE+DMRuJ2pgD3VmSRq8/p8WhQr+2gFcl6c1YCWnAjku/XqrKfTt
x60sTj8Ku/eqgnMBmgTGfTSIsOOW13tApY8NBw5zczZO4Y+K85c2bKNuO+LKGriBkv8+Yw49Ti+m
Kq3mLr2aT0dLDd2EmvyTDC5UmUY3XXfpMtGSuqhEVS0gUD2TyU5bOfoDctLXAU8euaxLtWPPO4y5
5tnD0wo5h5K6kXDOp7DVBOT+7B8Irrmejfb7Z3dhGZTzs4h+lcq15ZBx+dXi+22YtEv2tOQXgJzP
wldJ0E3zOGFBoSV1b49ELTkDRm2tmSZHtUB1tzWiQJwLRklb3CQUQnjAzwu1Nr4YerzHwu/wNRPD
uI1sDWnS/KWX5SNUCkPRwTbd5mDuuuD8EgyBb3QD49wfI9gJJwUjXwnedSvXSG+SwBSluPqlQ8HK
cku+xJvsmUqcko9VEYn85TFtqDhxGMiTlmTtB0w+CrNWyVJwdss08zq18cRvR92odbP4dCoDMe4A
S6A=
=v04Z
-----END PGP SIGNATURE-----

--------------0lOLE90wJNsb39RLAMUItepY--
