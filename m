From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Fri, 28 Apr 2023 14:18:38 +0000
Subject: Re: [PATCH v2 5/5] fbdev: Define framebuffer I/O from Linux' I/O functions
Message-Id: <900eaf1c-4d29-2c26-c220-6b4e089d9b94@suse.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------c0F146zPaNsO7viNjr1zOXUQ"
List-Id: <linux-ia64.vger.kernel.org>
References: <20230428092711.406-1-tzimmermann@suse.de>
 <20230428092711.406-6-tzimmermann@suse.de>
 <20230428131221.GE3995435@ravnborg.org>
In-Reply-To: <20230428131221.GE3995435@ravnborg.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--------------c0F146zPaNsO7viNjr1zOXUQ
Content-Type: multipart/mixed; boundary="------------Zz5vCKFZk2N0vxBo31k95sox";
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
Message-ID: <900eaf1c-4d29-2c26-c220-6b4e089d9b94@suse.de>
Subject: Re: [PATCH v2 5/5] fbdev: Define framebuffer I/O from Linux' I/O
 functions
References: <20230428092711.406-1-tzimmermann@suse.de>
 <20230428092711.406-6-tzimmermann@suse.de>
 <20230428131221.GE3995435@ravnborg.org>
In-Reply-To: <20230428131221.GE3995435@ravnborg.org>

--------------Zz5vCKFZk2N0vxBo31k95sox
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: base64

SGkNCg0KQW0gMjguMDQuMjMgdW0gMTU6MTIgc2NocmllYiBTYW0gUmF2bmJvcmc6DQo+IEhp
IFRob21hcywNCj4gDQo+IE9uIEZyaSwgQXByIDI4LCAyMDIzIGF0IDExOjI3OjExQU0gKzAy
MDAsIFRob21hcyBaaW1tZXJtYW5uIHdyb3RlOg0KPj4gSW1wbGVtZW50IGZyYW1lYnVmZmVy
IEkvTyBoZWxwZXJzLCBzdWNoIGFzIGZiX3JlYWQqKCkgYW5kIGZiX3dyaXRlKigpDQo+PiB3
aXRoIExpbnV4JyByZWd1bGFyIEkvTyBmdW5jdGlvbnMuIFJlbW92ZSBhbGwgaWZkZWYgY2Fz
ZXMgZm9yIHRoZQ0KPj4gdmFyaW91cyBhcmNoaXRlY3R1cmVzLg0KPj4NCj4+IE1vc3Qgb2Yg
dGhlIHN1cHBvcnRlZCBhcmNoaXRlY3R1cmVzIHVzZSBfX3Jhd18oKSBJL08gZnVuY3Rpb25z
IG9yIHRyZWF0DQo+PiBmcmFtZWJ1ZmZlciBtZW1vcnkgbGlrZSByZWd1bGFyIG1lbW9yeS4g
VGhpcyBpcyBhbHNvIGltcGxlbWVudGVkIGJ5IHRoZQ0KPj4gYXJjaGl0ZWN0dXJlcycgSS9P
IGZ1bmN0aW9uLCBzbyB3ZSBjYW4gdXNlIHRoZW0gaW5zdGVhZC4NCj4+DQo+PiBTcGFyYyB1
c2VzIFNCdXMgdG8gY29ubmVjdCB0byBmcmFtZWJ1ZmZlciBkZXZpY2VzLiBJdCBwcm92aWRl
cyByZXNwZWN0aXZlDQo+PiBpbXBsZW1lbnRhdGlvbnMgb2YgdGhlIGZyYW1lYnVmZmVyIEkv
TyBoZWxwZXJzLiBUaGUgaW52b2x2ZWQgc2J1c18oKQ0KPj4gSS9PIGhlbHBlcnMgbWFwIHRv
IHRoZSBzYW1lIGNvZGUgYXMgU3BhcmMncyByZWd1bGFyIEkvTyBmdW5jdGlvbnMuIEFzDQo+
PiB3aXRoIG90aGVyIHBsYXRmb3Jtcywgd2UgY2FuIHVzZSB0aG9zZSBpbnN0ZWFkLg0KPj4N
Cj4+IFdlIGxlYXZlIGEgVE9ETyBpdGVtIHRvIHJlcGxhY2UgYWxsIGZiXygpIGZ1bmN0aW9u
cyB3aXRoIHRoZWlyIHJlZ3VsYXINCj4+IEkvTyBjb3VudGVycGFydHMgdGhyb3VnaG91dCB0
aGUgZmJkZXYgZHJpdmVycy4NCj4+DQo+PiBTaWduZWQtb2ZmLWJ5OiBUaG9tYXMgWmltbWVy
bWFubiA8dHppbW1lcm1hbm5Ac3VzZS5kZT4NCj4+IC0tLQ0KPj4gICBpbmNsdWRlL2xpbnV4
L2ZiLmggfCA2MyArKysrKysrKysrKy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tDQo+PiAgIDEgZmlsZSBjaGFuZ2VkLCAxNSBpbnNlcnRpb25zKCspLCA0OCBkZWxldGlv
bnMoLSkNCj4+DQo+PiBkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9mYi5oIGIvaW5jbHVk
ZS9saW51eC9mYi5oDQo+PiBpbmRleCAwOGNiNDdkYTcxZjguLjRhYTllOTBlZGQxNyAxMDA2
NDQNCj4+IC0tLSBhL2luY2x1ZGUvbGludXgvZmIuaA0KPj4gKysrIGIvaW5jbHVkZS9saW51
eC9mYi5oDQo+PiBAQCAtMTUsNyArMTUsNiBAQA0KPj4gICAjaW5jbHVkZSA8bGludXgvbGlz
dC5oPg0KPj4gICAjaW5jbHVkZSA8bGludXgvYmFja2xpZ2h0Lmg+DQo+PiAgICNpbmNsdWRl
IDxsaW51eC9zbGFiLmg+DQo+PiAtI2luY2x1ZGUgPGFzbS9pby5oPg0KPj4gICANCj4+ICAg
c3RydWN0IHZtX2FyZWFfc3RydWN0Ow0KPj4gICBzdHJ1Y3QgZmJfaW5mbzsNCj4+IEBAIC01
MTEsNTggKzUxMCwyNiBAQCBzdHJ1Y3QgZmJfaW5mbyB7DQo+PiAgICAqLw0KPj4gICAjZGVm
aW5lIFNUVVBJRF9BQ0NFTEZfVEVYVF9TSElUDQo+PiAgIA0KPj4gLS8vIFRoaXMgd2lsbCBn
byBhd2F5DQo+PiAtI2lmIGRlZmluZWQoX19zcGFyY19fKQ0KPj4gLQ0KPj4gLS8qIFdlIG1h
cCBhbGwgb2Ygb3VyIGZyYW1lYnVmZmVycyBzdWNoIHRoYXQgYmlnLWVuZGlhbiBhY2Nlc3Nl
cw0KPj4gLSAqIGFyZSB3aGF0IHdlIHdhbnQsIHNvIHRoZSBmb2xsb3dpbmcgaXMgc3VmZmlj
aWVudC4NCj4+ICsvKg0KPj4gKyAqIFRPRE86IFVwZGF0ZSBmYmRldiBkcml2ZXJzIHRvIGNh
bGwgdGhlIEkvTyBoZWxwZXJzIGRpcmVjdGx5IGFuZA0KPj4gKyAqICAgICAgIHJlbW92ZSB0
aGUgZmJfKCkgdG9rZW5zLg0KPj4gICAgKi8NCj4gV2hlbiB0aGUgX19yYXdfKiB2YXJpYW50
cyBhcmUgdXNlZCwgYXMgR2VlcnQgcG9pbnRzIG91dCwgdGhlbiBJIHRoaW5rDQo+IHRoZSBt
ZW1jcHkgLyBtZW1zZXQgY2FuIGJlIHJlcGxhY2VkLCBidXQgdGhlIHJlc3Qgc2VlbXMgZmlu
ZSB0byBrZWVwLg0KDQpJJ2QgZWl0aGVyIHdhbnQgdGhlIHJlZ3VsYXIgSS9PIGZ1bmN0aW9u
cyBvciB0aGUgZmJfKCkgd3JhcHBlcnMsIGJ1dCBub3QgDQp0aGUgX19yYXdfKCkgZnVuY3Rp
b24uIEknZCBhbHNvIHByZWZlciB0byBrZWVwIGZiXyBpbiBmcm9udCBvZiBtZW1zZXQgDQph
bmQgbWVtY3B5LiAgSSdkIGJlIGhhcHB5IHRvIGhhdmUgZmJfKCkgd3JhcHBlcnMgdGhhdCBh
cmUgSS9PIGhlbHBlcnMgDQp3aXRob3V0IG9yZGVyaW5nIGd1YXJhbnRlZXMuIEknZCBqdXN0
IHdvdWxkbid0IHdhbnQgdGhlbSBpbiA8bGludXgvZmIuaD4NCg0KQmVzdCByZWdhcmRzDQpU
aG9tYXMNCg0KPiANCj4gTXkgcGVyc29uYWwgb3BpbmlvbiBpcyB0aGF0IF9fcmF3XyogaXMg
Zm9yIG1hY3JvIHVzZSBldGMsIGFuZCBub3QNCj4gc29tZXRoaW5nIHRvIHVzZSBldmVyeXdo
ZXJlLiBTbyBJIGxpa2UgdGhlIGZiX3JlYWQvZmJfd3JpdGUgbWFjcm9zLg0KPiBCdXQgdGhh
dCBpcyBqdXN0IG15IGNvbG9yIG9mIHRoZSBiaWtlc2hlZC4NCj4gDQo+IAlTYW0NCg0KLS0g
DQpUaG9tYXMgWmltbWVybWFubg0KR3JhcGhpY3MgRHJpdmVyIERldmVsb3Blcg0KU1VTRSBT
b2Z0d2FyZSBTb2x1dGlvbnMgR2VybWFueSBHbWJIDQpGcmFua2Vuc3RyYXNzZSAxNDYsIDkw
NDYxIE51ZXJuYmVyZywgR2VybWFueQ0KR0Y6IEl2byBUb3RldiwgQW5kcmV3IE15ZXJzLCBB
bmRyZXcgTWNEb25hbGQsIEJvdWRpZW4gTW9lcm1hbg0KSFJCIDM2ODA5IChBRyBOdWVybmJl
cmcpDQo=

--------------Zz5vCKFZk2N0vxBo31k95sox--

--------------c0F146zPaNsO7viNjr1zOXUQ
Content-Type: application/pgp-signature; name="OpenPGP_signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="OpenPGP_signature"

-----BEGIN PGP SIGNATURE-----

wsF5BAABCAAjFiEExndm/fpuMUdwYFFolh/E3EQov+AFAmRL1b4FAwAAAAAACgkQlh/E3EQov+Ds
HA/9FboYwhheuV2afpQ/SaP1wYDQp07GWmCD6BrWFr+zcYG0SXAkFjvnnZwIE5sxgx63yJaTIS2k
HClkJ6q89fGY/8XISiOhMZDZMO01vbT54iMD9/d/ARiq3sbP6le7jGjhQNf4qQxwChm75nPiRNuk
3DrW9Rd5y5V7zBu5S66Qc+Qa5froBkkkdK6SxeCWHI7IN7uQ/SaA7+MIhoWf6nsShyJIgfXr6Ari
pUx/2n169Cxc34R3ftRVWrInl5pACavFjtXeW9uWHV7HNVWCPby74kN8FYS4SX2V0jDpwiCCMZmd
i2dSuHltV+jyQxEnMhwLRUstXz7n+hnpsIt1qffv8sW5hS2Vz7FIJV1Uf5OQ6Kj+J3iqI6mmb3eW
EtaFwAfj4LB2EaD3pKcZ9M3WjfiXC6+cVQR+cf6jJDJWoJGfbr3KpDFIEa1mMjWrPBM8QGGIGtqv
IfD1TrCQNzo0rb14BPTt0S7UVt8VSCGbLeyZpmiAczti8t6t0rkFS5eCHCfW1rBcRdg0Tn1BsQqm
aE+xNNstqNLpPRpGSvL7AFAbTbpzLJQAeeg58YkytjUB+xq7gQl4Ssff+c99NZZSCKKQM+wRrCpz
nlUyb+lA/nVwARQwrCNXHhxtG9aKcmQ5UcwCWDLGzrPcdLtptct1CdM0YwJqKl6++eigX63ysIgT
+1c=
=t+WE
-----END PGP SIGNATURE-----

--------------c0F146zPaNsO7viNjr1zOXUQ--
