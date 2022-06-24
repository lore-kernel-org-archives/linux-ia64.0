From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Fri, 24 Jun 2022 05:28:48 +0000
Subject: Re: [PATCH V4 02/26] mm/mmap: Define DECLARE_VM_GET_PAGE_PROT
Message-Id: <d3676fce-2dc7-6331-66f5-7009ac45f605@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220624044339.1533882-1-anshuman.khandual@arm.com>
 <20220624044339.1533882-3-anshuman.khandual@arm.com>
In-Reply-To: <20220624044339.1533882-3-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "hch@infradead.org" <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

DQoNCkxlIDI0LzA2LzIwMjIgw6AgMDY6NDMsIEFuc2h1bWFuIEtoYW5kdWFsIGEgw6ljcml0wqA6
DQo+IFRoaXMganVzdCBjb252ZXJ0cyB0aGUgZ2VuZXJpYyB2bV9nZXRfcGFnZV9wcm90KCkgaW1w
bGVtZW50YXRpb24gaW50byBhIG5ldw0KPiBtYWNybyBpLmUgREVDTEFSRV9WTV9HRVRfUEFHRV9Q
Uk9UIHdoaWNoIGxhdGVyIGNhbiBiZSB1c2VkIGFjcm9zcyBwbGF0Zm9ybXMNCj4gd2hlbiBlbmFi
bGluZyB0aGVtIHdpdGggQVJDSF9IQVNfVk1fR0VUX1BBR0VfUFJPVC4gVGhpcyBkb2VzIG5vdCBj
cmVhdGUgYW55DQo+IGZ1bmN0aW9uYWwgY2hhbmdlLg0KPiANCj4gQ2M6IEFuZHJldyBNb3J0b24g
PGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc+DQo+IENjOiBsaW51eC1tbUBrdmFjay5vcmcNCj4g
Q2M6IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4gU3VnZ2VzdGVkLWJ5OiBDaHJpc3Rv
cGggSGVsbHdpZyA8aGNoQGluZnJhZGVhZC5vcmc+DQo+IFNpZ25lZC1vZmYtYnk6IEFuc2h1bWFu
IEtoYW5kdWFsIDxhbnNodW1hbi5raGFuZHVhbEBhcm0uY29tPg0KPiAtLS0NCj4gICBpbmNsdWRl
L2xpbnV4L21tLmggfCA4ICsrKysrKysrDQo+ICAgbW0vbW1hcC5jICAgICAgICAgIHwgNiArLS0t
LS0NCj4gICAyIGZpbGVzIGNoYW5nZWQsIDkgaW5zZXJ0aW9ucygrKSwgNSBkZWxldGlvbnMoLSkN
Cj4gDQo+IGRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L21tLmggYi9pbmNsdWRlL2xpbnV4L21t
LmgNCj4gaW5kZXggNDdiZmUwMzhkNDZlLi4yMzc4MjhjMmJhZTIgMTAwNjQ0DQo+IC0tLSBhL2lu
Y2x1ZGUvbGludXgvbW0uaA0KPiArKysgYi9pbmNsdWRlL2xpbnV4L21tLmgNCj4gQEAgLTQyOCw2
ICs0MjgsMTQgQEAgZXh0ZXJuIHVuc2lnbmVkIGludCBrb2Jqc2l6ZShjb25zdCB2b2lkICpvYmpw
KTsNCj4gICBleHRlcm4gcGdwcm90X3QgcHJvdGVjdGlvbl9tYXBbMTZdOw0KPiAgICNlbmRpZg0K
PiAgIA0KDQpJIHRoaW5rIHRoZSBjb21tZW50IGFib3ZlIHByb3RlY3Rpb25fbWFwWzE2XSBpbiBt
bS9tbWFwLmMgc2hvdWxkIGJlIA0KbW92ZWQgaGVyZS4NCg0KPiArI2RlZmluZSBERUNMQVJFX1ZN
X0dFVF9QQUdFX1BST1QJCQkJCVwNCj4gK3BncHJvdF90IHZtX2dldF9wYWdlX3Byb3QodW5zaWdu
ZWQgbG9uZyB2bV9mbGFncykJCQlcDQo+ICt7CQkJCQkJCQkJXA0KPiArCQlyZXR1cm4gcHJvdGVj
dGlvbl9tYXBbdm1fZmxhZ3MgJgkJCVwNCj4gKwkJCShWTV9SRUFEIHwgVk1fV1JJVEUgfCBWTV9F
WEVDIHwgVk1fU0hBUkVEKV07CVwNCj4gK30JCQkJCQkJCQlcDQo+ICtFWFBPUlRfU1lNQk9MKHZt
X2dldF9wYWdlX3Byb3QpOw0KPiArDQo+ICAgLyoNCj4gICAgKiBUaGUgZGVmYXVsdCBmYXVsdCBm
bGFncyB0aGF0IHNob3VsZCBiZSB1c2VkIGJ5IG1vc3Qgb2YgdGhlDQo+ICAgICogYXJjaC1zcGVj
aWZpYyBwYWdlIGZhdWx0IGhhbmRsZXJzLg0KPiBkaWZmIC0tZ2l0IGEvbW0vbW1hcC5jIGIvbW0v
bW1hcC5jDQo+IGluZGV4IGIwMWYwMjgwYmRhMi4uNTVjMzBhZWUzOTk5IDEwMDY0NA0KPiAtLS0g
YS9tbS9tbWFwLmMNCj4gKysrIGIvbW0vbW1hcC5jDQo+IEBAIC0xMjMsMTEgKzEyMyw3IEBAIHBn
cHJvdF90IHByb3RlY3Rpb25fbWFwWzE2XSBfX3JvX2FmdGVyX2luaXQgPSB7DQo+ICAgI2VuZGlm
DQo+ICAgDQo+ICAgI2lmbmRlZiBDT05GSUdfQVJDSF9IQVNfVk1fR0VUX1BBR0VfUFJPVA0KPiAt
cGdwcm90X3Qgdm1fZ2V0X3BhZ2VfcHJvdCh1bnNpZ25lZCBsb25nIHZtX2ZsYWdzKQ0KPiAtew0K
PiAtCXJldHVybiBwcm90ZWN0aW9uX21hcFt2bV9mbGFncyAmIChWTV9SRUFEfFZNX1dSSVRFfFZN
X0VYRUN8Vk1fU0hBUkVEKV07DQo+IC19DQo+IC1FWFBPUlRfU1lNQk9MKHZtX2dldF9wYWdlX3By
b3QpOw0KPiArREVDTEFSRV9WTV9HRVRfUEFHRV9QUk9UDQo+ICAgI2VuZGlmCS8qIENPTkZJR19B
UkNIX0hBU19WTV9HRVRfUEFHRV9QUk9UICovDQo+ICAgDQo+ICAgc3RhdGljIHBncHJvdF90IHZt
X3BncHJvdF9tb2RpZnkocGdwcm90X3Qgb2xkcHJvdCwgdW5zaWduZWQgbG9uZyB2bV9mbGFncyk
