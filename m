From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Mon, 27 Jun 2022 05:49:26 +0000
Subject: Re: [PATCH V5 01/26] mm/mmap: Build protect protection_map[] with __P000
Message-Id: <d273b5e5-ebb9-b279-b9f7-a595494afa53@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220627045833.1590055-1-anshuman.khandual@arm.com>
 <20220627045833.1590055-2-anshuman.khandual@arm.com>
In-Reply-To: <20220627045833.1590055-2-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "hch@infradead.org" <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

DQoNCkxlIDI3LzA2LzIwMjIgw6AgMDY6NTgsIEFuc2h1bWFuIEtoYW5kdWFsIGEgw6ljcml0wqA6
DQo+IEJ1aWxkIHByb3RlY3QgZ2VuZXJpYyBwcm90ZWN0aW9uX21hcFtdIGFycmF5IHdpdGggX19Q
MDAwLCBzbyB0aGF0IGl0IGNhbiBiZQ0KPiBtb3ZlZCBpbnNpZGUgYWxsIHRoZSBwbGF0Zm9ybXMg
b25lIGFmdGVyIHRoZSBvdGhlci4gT3RoZXJ3aXNlIHRoZXJlIHdpbGwgYmUNCj4gYnVpbGQgZmFp
bHVyZXMgZHVyaW5nIHRoaXMgcHJvY2Vzcy4gQ09ORklHX0FSQ0hfSEFTX1ZNX0dFVF9QQUdFX1BS
T1QgY2Fubm90DQo+IGJlIHVzZWQgZm9yIHRoaXMgcHVycG9zZSBhcyBvbmx5IGNlcnRhaW4gcGxh
dGZvcm1zIGVuYWJsZSB0aGlzIGNvbmZpZyBub3cuDQo+IA0KPiBDYzogQW5kcmV3IE1vcnRvbiA8
YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZz4NCj4gQ2M6IGxpbnV4LW1tQGt2YWNrLm9yZw0KPiBD
YzogbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZw0KPiBSZXZpZXdlZC1ieTogQ2hyaXN0b3Bo
IEhlbGx3aWcgPGhjaEBsc3QuZGU+DQo+IFN1Z2dlc3RlZC1ieTogQ2hyaXN0b3BoZSBMZXJveSA8
Y2hyaXN0b3BoZS5sZXJveUBjc2dyb3VwLmV1Pg0KPiBTaWduZWQtb2ZmLWJ5OiBBbnNodW1hbiBL
aGFuZHVhbCA8YW5zaHVtYW4ua2hhbmR1YWxAYXJtLmNvbT4NCg0KUmV2aWV3ZWQtYnk6IENocmlz
dG9waGUgTGVyb3kgPGNocmlzdG9waGUubGVyb3lAY3Nncm91cC5ldT4NCg0KPiAtLS0NCj4gICBp
bmNsdWRlL2xpbnV4L21tLmggfCAyICsrDQo+ICAgbW0vbW1hcC5jICAgICAgICAgIHwgMiArKw0K
PiAgIDIgZmlsZXMgY2hhbmdlZCwgNCBpbnNlcnRpb25zKCspDQo+IA0KPiBkaWZmIC0tZ2l0IGEv
aW5jbHVkZS9saW51eC9tbS5oIGIvaW5jbHVkZS9saW51eC9tbS5oDQo+IGluZGV4IGJjOGYzMjZi
ZTBjZS4uNDdiZmUwMzhkNDZlIDEwMDY0NA0KPiAtLS0gYS9pbmNsdWRlL2xpbnV4L21tLmgNCj4g
KysrIGIvaW5jbHVkZS9saW51eC9tbS5oDQo+IEBAIC00MjQsNyArNDI0LDkgQEAgZXh0ZXJuIHVu
c2lnbmVkIGludCBrb2Jqc2l6ZShjb25zdCB2b2lkICpvYmpwKTsNCj4gICAgKiBtYXBwaW5nIGZy
b20gdGhlIGN1cnJlbnRseSBhY3RpdmUgdm1fZmxhZ3MgcHJvdGVjdGlvbiBiaXRzICh0aGUNCj4g
ICAgKiBsb3cgZm91ciBiaXRzKSB0byBhIHBhZ2UgcHJvdGVjdGlvbiBtYXNrLi4NCj4gICAgKi8N
Cj4gKyNpZmRlZiBfX1AwMDANCj4gICBleHRlcm4gcGdwcm90X3QgcHJvdGVjdGlvbl9tYXBbMTZd
Ow0KPiArI2VuZGlmDQo+ICAgDQo+ICAgLyoNCj4gICAgKiBUaGUgZGVmYXVsdCBmYXVsdCBmbGFn
cyB0aGF0IHNob3VsZCBiZSB1c2VkIGJ5IG1vc3Qgb2YgdGhlDQo+IGRpZmYgLS1naXQgYS9tbS9t
bWFwLmMgYi9tbS9tbWFwLmMNCj4gaW5kZXggNjFlNjEzNWM1NGVmLi5iMDFmMDI4MGJkYTIgMTAw
NjQ0DQo+IC0tLSBhL21tL21tYXAuYw0KPiArKysgYi9tbS9tbWFwLmMNCj4gQEAgLTEwMSw2ICsx
MDEsNyBAQCBzdGF0aWMgdm9pZCB1bm1hcF9yZWdpb24oc3RydWN0IG1tX3N0cnVjdCAqbW0sDQo+
ICAgICoJCQkJCQkJCXc6IChubykgbm8NCj4gICAgKgkJCQkJCQkJeDogKHllcykgeWVzDQo+ICAg
ICovDQo+ICsjaWZkZWYgX19QMDAwDQo+ICAgcGdwcm90X3QgcHJvdGVjdGlvbl9tYXBbMTZdIF9f
cm9fYWZ0ZXJfaW5pdCA9IHsNCj4gICAJW1ZNX05PTkVdCQkJCQk9IF9fUDAwMCwNCj4gICAJW1ZN
X1JFQURdCQkJCQk9IF9fUDAwMSwNCj4gQEAgLTExOSw2ICsxMjAsNyBAQCBwZ3Byb3RfdCBwcm90
ZWN0aW9uX21hcFsxNl0gX19yb19hZnRlcl9pbml0ID0gew0KPiAgIAlbVk1fU0hBUkVEIHwgVk1f
RVhFQyB8IFZNX1dSSVRFXQkJPSBfX1MxMTAsDQo+ICAgCVtWTV9TSEFSRUQgfCBWTV9FWEVDIHwg
Vk1fV1JJVEUgfCBWTV9SRUFEXQk9IF9fUzExMQ0KPiAgIH07DQo+ICsjZW5kaWYNCj4gICANCj4g
ICAjaWZuZGVmIENPTkZJR19BUkNIX0hBU19WTV9HRVRfUEFHRV9QUk9UDQo+ICAgcGdwcm90X3Qg
dm1fZ2V0X3BhZ2VfcHJvdCh1bnNpZ25lZCBsb25nIHZtX2ZsYWdzKQ=
