From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Mon, 27 Jun 2022 05:48:16 +0000
Subject: Re: [PATCH V4 07/26] mm/mmap: Build protect protection_map[] with ARCH_HAS_VM_GET_PAGE_PROT
Message-Id: <34116484-b5fe-3be7-b93e-0969510ba2d8@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220624044339.1533882-1-anshuman.khandual@arm.com>
 <20220624044339.1533882-8-anshuman.khandual@arm.com>
In-Reply-To: <20220624044339.1533882-8-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "hch@infradead.org" <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

DQoNCkxlIDI0LzA2LzIwMjIgw6AgMDY6NDMsIEFuc2h1bWFuIEtoYW5kdWFsIGEgw6ljcml0wqA6
DQo+IHByb3RlY3Rpb25fbWFwW10gaGFzIGFscmVhZHkgYmVlbiBtb3ZlZCBpbnNpZGUgdGhvc2Ug
cGxhdGZvcm1zIHdoaWNoIGVuYWJsZQ0KPiBBUkNIX0hBU19WTV9HRVRfUEFHRV9QUk9ULiBIZW5j
ZSBnZW5lcmljIHByb3RlY3Rpb25fbWFwW10gYXJyYXkgbm93IGNhbiBiZQ0KPiBwcm90ZWN0ZWQg
d2l0aCBDT05GSUdfQVJDSF9IQVNfVk1fR0VUX1BBR0VfUFJPVCBpbnRlYWQgb2YgX19QMDAwLg0K
PiANCj4gQ2M6IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc+DQo+IENj
OiBsaW51eC1tbUBrdmFjay5vcmcNCj4gQ2M6IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcN
Cj4gU2lnbmVkLW9mZi1ieTogQW5zaHVtYW4gS2hhbmR1YWwgPGFuc2h1bWFuLmtoYW5kdWFsQGFy
bS5jb20+DQoNClJldmlld2VkLWJ5OiBDaHJpc3RvcGhlIExlcm95IDxjaHJpc3RvcGhlLmxlcm95
QGNzZ3JvdXAuZXU+DQoNCj4gLS0tDQo+ICAgaW5jbHVkZS9saW51eC9tbS5oIHwgMiArLQ0KPiAg
IG1tL21tYXAuYyAgICAgICAgICB8IDUgKy0tLS0NCj4gICAyIGZpbGVzIGNoYW5nZWQsIDIgaW5z
ZXJ0aW9ucygrKSwgNSBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9pbmNsdWRlL2xp
bnV4L21tLmggYi9pbmNsdWRlL2xpbnV4L21tLmgNCj4gaW5kZXggMjM3ODI4YzJiYWUyLi43MGQ5
MDBmNmRmNDMgMTAwNjQ0DQo+IC0tLSBhL2luY2x1ZGUvbGludXgvbW0uaA0KPiArKysgYi9pbmNs
dWRlL2xpbnV4L21tLmgNCj4gQEAgLTQyNCw3ICs0MjQsNyBAQCBleHRlcm4gdW5zaWduZWQgaW50
IGtvYmpzaXplKGNvbnN0IHZvaWQgKm9ianApOw0KPiAgICAqIG1hcHBpbmcgZnJvbSB0aGUgY3Vy
cmVudGx5IGFjdGl2ZSB2bV9mbGFncyBwcm90ZWN0aW9uIGJpdHMgKHRoZQ0KPiAgICAqIGxvdyBm
b3VyIGJpdHMpIHRvIGEgcGFnZSBwcm90ZWN0aW9uIG1hc2suLg0KPiAgICAqLw0KPiAtI2lmZGVm
IF9fUDAwMA0KPiArI2lmbmRlZiBDT05GSUdfQVJDSF9IQVNfVk1fR0VUX1BBR0VfUFJPVA0KPiAg
IGV4dGVybiBwZ3Byb3RfdCBwcm90ZWN0aW9uX21hcFsxNl07DQo+ICAgI2VuZGlmDQo+ICAgDQo+
IGRpZmYgLS1naXQgYS9tbS9tbWFwLmMgYi9tbS9tbWFwLmMNCj4gaW5kZXggNTVjMzBhZWUzOTk5
Li40M2RiM2JkNDkwNzEgMTAwNjQ0DQo+IC0tLSBhL21tL21tYXAuYw0KPiArKysgYi9tbS9tbWFw
LmMNCj4gQEAgLTEwMSw3ICsxMDEsNyBAQCBzdGF0aWMgdm9pZCB1bm1hcF9yZWdpb24oc3RydWN0
IG1tX3N0cnVjdCAqbW0sDQo+ICAgICoJCQkJCQkJCXc6IChubykgbm8NCj4gICAgKgkJCQkJCQkJ
eDogKHllcykgeWVzDQo+ICAgICovDQo+IC0jaWZkZWYgX19QMDAwDQo+ICsjaWZuZGVmIENPTkZJ
R19BUkNIX0hBU19WTV9HRVRfUEFHRV9QUk9UDQo+ICAgcGdwcm90X3QgcHJvdGVjdGlvbl9tYXBb
MTZdIF9fcm9fYWZ0ZXJfaW5pdCA9IHsNCj4gICAJW1ZNX05PTkVdCQkJCQk9IF9fUDAwMCwNCj4g
ICAJW1ZNX1JFQURdCQkJCQk9IF9fUDAwMSwNCj4gQEAgLTEyMCw5ICsxMjAsNiBAQCBwZ3Byb3Rf
dCBwcm90ZWN0aW9uX21hcFsxNl0gX19yb19hZnRlcl9pbml0ID0gew0KPiAgIAlbVk1fU0hBUkVE
IHwgVk1fRVhFQyB8IFZNX1dSSVRFXQkJPSBfX1MxMTAsDQo+ICAgCVtWTV9TSEFSRUQgfCBWTV9F
WEVDIHwgVk1fV1JJVEUgfCBWTV9SRUFEXQk9IF9fUzExMQ0KPiAgIH07DQo+IC0jZW5kaWYNCj4g
LQ0KPiAtI2lmbmRlZiBDT05GSUdfQVJDSF9IQVNfVk1fR0VUX1BBR0VfUFJPVA0KPiAgIERFQ0xB
UkVfVk1fR0VUX1BBR0VfUFJPVA0KPiAgICNlbmRpZgkvKiBDT05GSUdfQVJDSF9IQVNfVk1fR0VU
X1BBR0VfUFJPVCAqLw0KPiAgIA=
