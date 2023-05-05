From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Fri, 05 May 2023 07:01:32 +0000
Subject: Re: [PATCH v4 0/6] fbdev: Move framebuffer I/O helpers to <asm/fb.h>
Message-Id: <30ffdab2-486d-b35d-8899-8de1636f6067@suse.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------0Bv3Rp4OGkrWFSYFX7f0sTJt"
List-Id: <linux-ia64.vger.kernel.org>
References: <20230504074539.8181-1-tzimmermann@suse.de>
 <ee4cea3d-282e-4e90-897e-4ba576731f6e@app.fastmail.com>
In-Reply-To: <ee4cea3d-282e-4e90-897e-4ba576731f6e@app.fastmail.com>
To: Arnd Bergmann <arnd@arndb.de>, Helge Deller <deller@gmx.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Javier Martinez Canillas <javierm@redhat.com>, Daniel Vetter <daniel@ffwll.ch>, Vineet Gupta <vgupta@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, "David S . Miller" <davem@davemloft.net>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Sam Ravnborg <sam@ravnborg.org>
Cc: linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--------------0Bv3Rp4OGkrWFSYFX7f0sTJt
Content-Type: multipart/mixed; boundary="------------iHUuUQd57sMmOodRakb4y5yZ";
 protected-headers="v1"
From: Thomas Zimmermann <tzimmermann@suse.de>
To: Arnd Bergmann <arnd@arndb.de>, Helge Deller <deller@gmx.de>,
 Geert Uytterhoeven <geert@linux-m68k.org>,
 Javier Martinez Canillas <javierm@redhat.com>,
 Daniel Vetter <daniel@ffwll.ch>, Vineet Gupta <vgupta@kernel.org>,
 Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>,
 "David S . Miller" <davem@davemloft.net>,
 "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>,
 Sam Ravnborg <sam@ravnborg.org>
Cc: linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org,
 Linux-Arch <linux-arch@vger.kernel.org>, linux-snps-arc@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
 loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org,
 sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-parisc@vger.kernel.org
Message-ID: <30ffdab2-486d-b35d-8899-8de1636f6067@suse.de>
Subject: Re: [PATCH v4 0/6] fbdev: Move framebuffer I/O helpers to <asm/fb.h>
References: <20230504074539.8181-1-tzimmermann@suse.de>
 <ee4cea3d-282e-4e90-897e-4ba576731f6e@app.fastmail.com>
In-Reply-To: <ee4cea3d-282e-4e90-897e-4ba576731f6e@app.fastmail.com>

--------------iHUuUQd57sMmOodRakb4y5yZ
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: base64

SGkNCg0KQW0gMDQuMDUuMjMgdW0gMTA6MDggc2NocmllYiBBcm5kIEJlcmdtYW5uOg0KPiBP
biBUaHUsIE1heSA0LCAyMDIzLCBhdCAwOTo0NSwgVGhvbWFzIFppbW1lcm1hbm4gd3JvdGU6
DQo+PiBGYmRldiBwcm92aWRlcyBoZWxwZXJzIGZvciBmcmFtZWJ1ZmZlciBJL08sIHN1Y2gg
YXMgZmJfcmVhZGwoKSwNCj4+IGZiX3dyaXRlbCgpIG9yIGZiX21lbWNweV90b19mYigpLiBU
aGUgaW1wbGVtZW50YXRpb24gb2YgZWFjaCBoZWxwZXINCj4+IGRlcGVuZHMgb24gdGhlIGFy
Y2hpdGVjdHVyZSwgYnV0IHRoZXkgYXJlIGFsbCBlcXVpdmFsZW50IHRvIHJlZ3VsYXINCj4+
IEkvTyBmdW5jdGlvbnMgb2Ygc2ltaWxhciBuYW1lcy4gU28gdXNlIHJlZ3VsYXIgZnVuY3Rp
b25zIGluc3RlYWQgYW5kDQo+PiBtb3ZlIGFsbCBoZWxwZXJzIGludG8gPGFzbS1nZW5lcmlj
L2ZiLmg+DQo+Pg0KPj4gVGhlIGZpcnN0IHBhdGNoIGEgc2ltcGxlIHdoaXRlc3BhY2UgY2xl
YW51cC4NCj4+DQo+PiBVbnRpbCBub3csIDxsaW51eC9mYi5oPiBjb250YWluZWQgYW4gaW5j
bHVkZSBvZiA8YXNtL2lvLmg+LiBBcyB0aGlzDQo+PiB3aWxsIGdvIGF3YXksIHBhdGNoZXMg
MiB0byA0IHByZXBhcmUgaW5jbHVkZSBzdGF0ZW1lbnRzIGluIHRoZSB2YXJpb3VzDQo+PiBk
cml2ZXJzLiBTb3VyY2UgZmlsZXMgdGhhdCB1c2UgcmVndWxhciBJL08gaGVscGVycywgc3Vj
aCBhcyByZWFkbCgpLA0KPj4gbm93IGluY2x1ZGUgPGxpbnV4L2lvLmg+LiBTb3VyY2UgZmls
ZXMgdGhhdCB1c2UgZnJhbWVidWZmZXIgSS9PDQo+PiBoZWxwZXJzLCBzdWNoIGFzIGZiX3Jl
YWRsKCksIG5vdyBpbmNsdWRlIDxsaW51eC9mYi5oPi4NCj4+DQo+PiBQYXRjaCA1IHJlcGxh
Y2VzIHRoZSBhcmNoaXRlY3R1cmUtYmFzZWQgaWYtZWxzZSBicmFuY2hpbmcgaW4NCj4+IDxs
aW51eC9mYi5oPiBieSBoZWxwZXJzIGluIDxhc20tZ2VuZXJpYy9mYi5oPi4gQWxsIGhlbHBl
cnMgdXNlIExpbnV4Jw0KPj4gZXhpc3RpbmcgSS9PIGZ1bmN0aW9ucy4NCj4+DQo+PiBQYXRj
aCA2IGhhcm1vbml6ZXMgbmFtaW5nIGFtb25nIGZiZGV2IGFuZCBleGlzdGluZyBJL08gZnVu
Y3Rpb25zLg0KPj4NCj4+IFRoZSBwYXRjaHNldCBoYXMgYmVlbiBidWlsdCBmb3IgYSB2YXJp
ZXR5IG9mIHBsYXRmb3Jtcywgc3VjaCBhcyB4ODYtNjQsDQo+PiBhcm0sIGFhcmNoNjQsIHBw
YzY0LCBwYXJpc2MsIG02NGssIG1pcHMgYW5kIHNwYXJjLg0KPiANCj4gVGhlIHdob2xlIHNl
cmllcyBsb29rcyBnb29kIHRvIG1lIG5vdywNCg0KVGhpcyB3YXMgYSBiaXQgbW9yZSBlZmZv
cnQgdG8gdG8gdW50YW5nbGUgdGhhbiBJIGV4cGVjdGVkLiBUaGFua3MgZm9yIA0KeW91ciBo
ZWxwIHdpdGggY2xlYW5pbmcgdGhpcyB1cC4NCg0KQmVzdCByZWdhcmRzDQpUaG9tYXMNCg0K
PiANCj4gUmV2aWV3ZWQtYnk6IEFybmQgQmVyZ21hbm4gPGFybmRAYXJuZGIuZGU+DQoNCi0t
IA0KVGhvbWFzIFppbW1lcm1hbm4NCkdyYXBoaWNzIERyaXZlciBEZXZlbG9wZXINClNVU0Ug
U29mdHdhcmUgU29sdXRpb25zIEdlcm1hbnkgR21iSA0KRnJhbmtlbnN0cmFzc2UgMTQ2LCA5
MDQ2MSBOdWVybmJlcmcsIEdlcm1hbnkNCkdGOiBJdm8gVG90ZXYsIEFuZHJldyBNeWVycywg
QW5kcmV3IE1jRG9uYWxkLCBCb3VkaWVuIE1vZXJtYW4NCkhSQiAzNjgwOSAoQUcgTnVlcm5i
ZXJnKQ0K

--------------iHUuUQd57sMmOodRakb4y5yZ--

--------------0Bv3Rp4OGkrWFSYFX7f0sTJt
Content-Type: application/pgp-signature; name="OpenPGP_signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="OpenPGP_signature"

-----BEGIN PGP SIGNATURE-----

wsF5BAABCAAjFiEExndm/fpuMUdwYFFolh/E3EQov+AFAmRUqcwFAwAAAAAACgkQlh/E3EQov+At
rRAAjtO14yf8xqupqP7I6XTHVEn7ZAq4gsqna2SJlxVII7VFl0xNZkJ/bzkrqofejISW6ZDVrulZ
AdaiZwvvyINOW0eOrMvbQ30zXiQRnLFl5vqCOff8KANKdzv0UWtYcDB0hZoW9ZB4tR9r28Z8t6hu
zWEux5SGTWWv5Ki8WBVRWUfqLFpke7zWLgFvaeioIjkFewMDPOCVNe3jjhokz82aUHPDIFWVsdw4
PX0HXbu1SGbHDWCs3vWGirTj4DB29ZrOCKt4CC2C93MzPnivctZJ5kPoRo0RZ5DSFQvl4ZrHZPSu
mrGYeFHVBtBhPQKUcQK9gdDpglTq5G4nF8WHVR9uSJh4m/RbFH2qUpo8Mmf81k/oV2XQDBGhRYj5
A7bTNgR3eU40WzVAaOT/Gpk1LQJ5PZOWniZawUeUYWcuaQ0HDew8E379TRLg+4afDiydmtIPuGLm
PzZf7FBqGlLPEIYiX2rHuB2vAXnwJjzu8IVMMJuK92pWqWID7hRh5BseU4qzFJ+J0owVn8maFk7Z
nLRZrp1ma8yjo2FnliHu/GF2Qde1GMAVWRwJZPFqhnBZIzi7p7nyK3mC1qp2hYb9vJEG5i20NN6m
6PoUPFe5qpVKHk+YHZqV8UCNLpQBStZnfAQ3AGc862TpJxBEjC08+jhWdguhWuV+xJ3l7Wjr/WTc
S5Q=
=/ACB
-----END PGP SIGNATURE-----

--------------0Bv3Rp4OGkrWFSYFX7f0sTJt--
