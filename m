From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Mon, 27 Jun 2022 05:47:42 +0000
Subject: Re: [PATCH V4 01/26] mm/mmap: Build protect protection_map[] with __P000
Message-Id: <6d213700-9e7f-409a-3dc7-186eeae87099@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220624044339.1533882-1-anshuman.khandual@arm.com>
 <20220624044339.1533882-2-anshuman.khandual@arm.com>
In-Reply-To: <20220624044339.1533882-2-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "hch@infradead.org" <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

DQoNCkxlIDI0LzA2LzIwMjIgw6AgMDY6NDMsIEFuc2h1bWFuIEtoYW5kdWFsIGEgw6ljcml0wqA6
DQo+IEJ1aWxkIHByb3RlY3QgZ2VuZXJpYyBwcm90ZWN0aW9uX21hcFtdIGFycmF5IHdpdGggX19Q
MDAwLCBzbyB0aGF0IGl0IGNhbiBiZQ0KPiBtb3ZlZCBpbnNpZGUgYWxsIHRoZSBwbGF0Zm9ybXMg
b25lIGFmdGVyIHRoZSBvdGhlci4gT3RoZXJ3aXNlIHRoZXJlIHdpbGwgYmUNCj4gYnVpbGQgZmFp
bHVyZXMgZHVyaW5nIHRoaXMgcHJvY2Vzcy4gQ09ORklHX0FSQ0hfSEFTX1ZNX0dFVF9QQUdFX1BS
T1QgY2Fubm90DQo+IGJlIHVzZWQgZm9yIHRoaXMgcHVycG9zZSBhcyBvbmx5IGNlcnRhaW4gcGxh
dGZvcm1zIGVuYWJsZSB0aGlzIGNvbmZpZyBub3cuDQo+IA0KPiBDYzogQW5kcmV3IE1vcnRvbiA8
YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZz4NCj4gQ2M6IGxpbnV4LW1tQGt2YWNrLm9yZw0KPiBD
YzogbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZw0KPiBTdWdnZXN0ZWQtYnk6IENocmlzdG9w
aGUgTGVyb3kgPGNocmlzdG9waGUubGVyb3lAY3Nncm91cC5ldT4NCj4gU2lnbmVkLW9mZi1ieTog
QW5zaHVtYW4gS2hhbmR1YWwgPGFuc2h1bWFuLmtoYW5kdWFsQGFybS5jb20+DQoNClJldmlld2Vk
LWJ5OiBDaHJpc3RvcGhlIExlcm95IDxjaHJpc3RvcGhlLmxlcm95QGNzZ3JvdXAuZXU+DQoNCj4g
LS0tDQo+ICAgaW5jbHVkZS9saW51eC9tbS5oIHwgMiArKw0KPiAgIG1tL21tYXAuYyAgICAgICAg
ICB8IDIgKysNCj4gICAyIGZpbGVzIGNoYW5nZWQsIDQgaW5zZXJ0aW9ucygrKQ0KPiANCj4gZGlm
ZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvbW0uaCBiL2luY2x1ZGUvbGludXgvbW0uaA0KPiBpbmRl
eCBiYzhmMzI2YmUwY2UuLjQ3YmZlMDM4ZDQ2ZSAxMDA2NDQNCj4gLS0tIGEvaW5jbHVkZS9saW51
eC9tbS5oDQo+ICsrKyBiL2luY2x1ZGUvbGludXgvbW0uaA0KPiBAQCAtNDI0LDcgKzQyNCw5IEBA
IGV4dGVybiB1bnNpZ25lZCBpbnQga29ianNpemUoY29uc3Qgdm9pZCAqb2JqcCk7DQo+ICAgICog
bWFwcGluZyBmcm9tIHRoZSBjdXJyZW50bHkgYWN0aXZlIHZtX2ZsYWdzIHByb3RlY3Rpb24gYml0
cyAodGhlDQo+ICAgICogbG93IGZvdXIgYml0cykgdG8gYSBwYWdlIHByb3RlY3Rpb24gbWFzay4u
DQo+ICAgICovDQo+ICsjaWZkZWYgX19QMDAwDQo+ICAgZXh0ZXJuIHBncHJvdF90IHByb3RlY3Rp
b25fbWFwWzE2XTsNCj4gKyNlbmRpZg0KPiAgIA0KPiAgIC8qDQo+ICAgICogVGhlIGRlZmF1bHQg
ZmF1bHQgZmxhZ3MgdGhhdCBzaG91bGQgYmUgdXNlZCBieSBtb3N0IG9mIHRoZQ0KPiBkaWZmIC0t
Z2l0IGEvbW0vbW1hcC5jIGIvbW0vbW1hcC5jDQo+IGluZGV4IDYxZTYxMzVjNTRlZi4uYjAxZjAy
ODBiZGEyIDEwMDY0NA0KPiAtLS0gYS9tbS9tbWFwLmMNCj4gKysrIGIvbW0vbW1hcC5jDQo+IEBA
IC0xMDEsNiArMTAxLDcgQEAgc3RhdGljIHZvaWQgdW5tYXBfcmVnaW9uKHN0cnVjdCBtbV9zdHJ1
Y3QgKm1tLA0KPiAgICAqCQkJCQkJCQl3OiAobm8pIG5vDQo+ICAgICoJCQkJCQkJCXg6ICh5ZXMp
IHllcw0KPiAgICAqLw0KPiArI2lmZGVmIF9fUDAwMA0KPiAgIHBncHJvdF90IHByb3RlY3Rpb25f
bWFwWzE2XSBfX3JvX2FmdGVyX2luaXQgPSB7DQo+ICAgCVtWTV9OT05FXQkJCQkJPSBfX1AwMDAs
DQo+ICAgCVtWTV9SRUFEXQkJCQkJPSBfX1AwMDEsDQo+IEBAIC0xMTksNiArMTIwLDcgQEAgcGdw
cm90X3QgcHJvdGVjdGlvbl9tYXBbMTZdIF9fcm9fYWZ0ZXJfaW5pdCA9IHsNCj4gICAJW1ZNX1NI
QVJFRCB8IFZNX0VYRUMgfCBWTV9XUklURV0JCT0gX19TMTEwLA0KPiAgIAlbVk1fU0hBUkVEIHwg
Vk1fRVhFQyB8IFZNX1dSSVRFIHwgVk1fUkVBRF0JPSBfX1MxMTENCj4gICB9Ow0KPiArI2VuZGlm
DQo+ICAgDQo+ICAgI2lmbmRlZiBDT05GSUdfQVJDSF9IQVNfVk1fR0VUX1BBR0VfUFJPVA0KPiAg
IHBncHJvdF90IHZtX2dldF9wYWdlX3Byb3QodW5zaWduZWQgbG9uZyB2bV9mbGFncyk
