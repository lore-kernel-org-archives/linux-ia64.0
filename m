From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Mon, 27 Jun 2022 05:47:55 +0000
Subject: Re: [PATCH V4 02/26] mm/mmap: Define DECLARE_VM_GET_PAGE_PROT
Message-Id: <f8140a0e-ab09-fea6-5a2f-76140b101482@csgroup.eu>
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
IEtoYW5kdWFsIDxhbnNodW1hbi5raGFuZHVhbEBhcm0uY29tPg0KDQpSZXZpZXdlZC1ieTogQ2hy
aXN0b3BoZSBMZXJveSA8Y2hyaXN0b3BoZS5sZXJveUBjc2dyb3VwLmV1Pg0KDQo+IC0tLQ0KPiAg
IGluY2x1ZGUvbGludXgvbW0uaCB8IDggKysrKysrKysNCj4gICBtbS9tbWFwLmMgICAgICAgICAg
fCA2ICstLS0tLQ0KPiAgIDIgZmlsZXMgY2hhbmdlZCwgOSBpbnNlcnRpb25zKCspLCA1IGRlbGV0
aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvbW0uaCBiL2luY2x1ZGUv
bGludXgvbW0uaA0KPiBpbmRleCA0N2JmZTAzOGQ0NmUuLjIzNzgyOGMyYmFlMiAxMDA2NDQNCj4g
LS0tIGEvaW5jbHVkZS9saW51eC9tbS5oDQo+ICsrKyBiL2luY2x1ZGUvbGludXgvbW0uaA0KPiBA
QCAtNDI4LDYgKzQyOCwxNCBAQCBleHRlcm4gdW5zaWduZWQgaW50IGtvYmpzaXplKGNvbnN0IHZv
aWQgKm9ianApOw0KPiAgIGV4dGVybiBwZ3Byb3RfdCBwcm90ZWN0aW9uX21hcFsxNl07DQo+ICAg
I2VuZGlmDQo+ICAgDQo+ICsjZGVmaW5lIERFQ0xBUkVfVk1fR0VUX1BBR0VfUFJPVAkJCQkJXA0K
PiArcGdwcm90X3Qgdm1fZ2V0X3BhZ2VfcHJvdCh1bnNpZ25lZCBsb25nIHZtX2ZsYWdzKQkJCVwN
Cj4gK3sJCQkJCQkJCQlcDQo+ICsJCXJldHVybiBwcm90ZWN0aW9uX21hcFt2bV9mbGFncyAmCQkJ
XA0KPiArCQkJKFZNX1JFQUQgfCBWTV9XUklURSB8IFZNX0VYRUMgfCBWTV9TSEFSRUQpXTsJXA0K
PiArfQkJCQkJCQkJCVwNCj4gK0VYUE9SVF9TWU1CT0wodm1fZ2V0X3BhZ2VfcHJvdCk7DQo+ICsN
Cj4gICAvKg0KPiAgICAqIFRoZSBkZWZhdWx0IGZhdWx0IGZsYWdzIHRoYXQgc2hvdWxkIGJlIHVz
ZWQgYnkgbW9zdCBvZiB0aGUNCj4gICAgKiBhcmNoLXNwZWNpZmljIHBhZ2UgZmF1bHQgaGFuZGxl
cnMuDQo+IGRpZmYgLS1naXQgYS9tbS9tbWFwLmMgYi9tbS9tbWFwLmMNCj4gaW5kZXggYjAxZjAy
ODBiZGEyLi41NWMzMGFlZTM5OTkgMTAwNjQ0DQo+IC0tLSBhL21tL21tYXAuYw0KPiArKysgYi9t
bS9tbWFwLmMNCj4gQEAgLTEyMywxMSArMTIzLDcgQEAgcGdwcm90X3QgcHJvdGVjdGlvbl9tYXBb
MTZdIF9fcm9fYWZ0ZXJfaW5pdCA9IHsNCj4gICAjZW5kaWYNCj4gICANCj4gICAjaWZuZGVmIENP
TkZJR19BUkNIX0hBU19WTV9HRVRfUEFHRV9QUk9UDQo+IC1wZ3Byb3RfdCB2bV9nZXRfcGFnZV9w
cm90KHVuc2lnbmVkIGxvbmcgdm1fZmxhZ3MpDQo+IC17DQo+IC0JcmV0dXJuIHByb3RlY3Rpb25f
bWFwW3ZtX2ZsYWdzICYgKFZNX1JFQUR8Vk1fV1JJVEV8Vk1fRVhFQ3xWTV9TSEFSRUQpXTsNCj4g
LX0NCj4gLUVYUE9SVF9TWU1CT0wodm1fZ2V0X3BhZ2VfcHJvdCk7DQo+ICtERUNMQVJFX1ZNX0dF
VF9QQUdFX1BST1QNCj4gICAjZW5kaWYJLyogQ09ORklHX0FSQ0hfSEFTX1ZNX0dFVF9QQUdFX1BS
T1QgKi8NCj4gICANCj4gICBzdGF0aWMgcGdwcm90X3Qgdm1fcGdwcm90X21vZGlmeShwZ3Byb3Rf
dCBvbGRwcm90LCB1bnNpZ25lZCBsb25nIHZtX2ZsYWdzKQ=
