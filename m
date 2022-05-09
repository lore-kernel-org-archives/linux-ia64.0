From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Mon, 09 May 2022 05:46:03 +0000
Subject: Re: [PATCH v2 1/3] mm: change huge_ptep_clear_flush() to return the original pte
Message-Id: <d5055b48-d722-e03d-fc32-16fd76e3fa22@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1652002221.git.baolin.wang@linux.alibaba.com>
 <012a484019e7ad77c39deab0af52a6755d8438c8.1652002221.git.baolin.wang@linux.alibaba.com>
 <Ynek+b3k6PVN3x7J@FVFYT0MHHV2J.usts.net>
 <bf627d1a-42f8-77f3-6ac2-67edde2feb8a@linux.alibaba.com>
In-Reply-To: <bf627d1a-42f8-77f3-6ac2-67edde2feb8a@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baolin Wang <baolin.wang@linux.alibaba.com>, Muchun Song <songmuchun@bytedance.com>
Cc: "dalias@libc.org" <dalias@libc.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "James.Bottomley@HansenPartnership.com" <James.Bottomley@HansenPartnership.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "paulus@samba.org" <paulus@samba.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "agordeev@linux.ibm.com" <agordeev@linux.ibm.com>, "will@kernel.org" <will@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>, "ysato@users.sourceforge.jp" <ysato@users.sourceforge.jp>, "deller@gmx.de" <deller@gmx.de>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "borntraeger@linux.ibm.com" <borntraeger@linux.ibm.com>, "gor@linux.ibm.com" <gor@linux.ibm.com>, "hca@linux.ibm.com" <hca@linux.ibm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "tsbogend@alpha.franken.de" <tsbogend@alpha.franken.de>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "svens@linux.ibm.com" <svens@linux.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "davem@davemloft.net" <davem@davemloft.net>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>

DQoNCkxlIDA4LzA1LzIwMjIgw6AgMTU6MDksIEJhb2xpbiBXYW5nIGEgw6ljcml0wqA6DQo+IA0K
PiANCj4gT24gNS84LzIwMjIgNzowOSBQTSwgTXVjaHVuIFNvbmcgd3JvdGU6DQo+PiBPbiBTdW4s
IE1heSAwOCwgMjAyMiBhdCAwNTozNjozOVBNICswODAwLCBCYW9saW4gV2FuZyB3cm90ZToNCj4+
PiBJdCBpcyBpbmNvcnJlY3QgdG8gdXNlIHB0ZXBfY2xlYXJfZmx1c2goKSB0byBudWtlIGEgaHVn
ZXRsYiBwYWdlDQo+Pj4gdGFibGUgd2hlbiB1bm1hcHBpbmcgb3IgbWlncmF0aW5nIGEgaHVnZXRs
YiBwYWdlLCBhbmQgd2lsbCBjaGFuZ2UNCj4+PiB0byB1c2UgaHVnZV9wdGVwX2NsZWFyX2ZsdXNo
KCkgaW5zdGVhZCBpbiB0aGUgZm9sbG93aW5nIHBhdGNoZXMuDQo+Pj4NCj4+PiBTbyB0aGlzIGlz
IGEgcHJlcGFyYXRpb24gcGF0Y2gsIHdoaWNoIGNoYW5nZXMgdGhlIA0KPj4+IGh1Z2VfcHRlcF9j
bGVhcl9mbHVzaCgpDQo+Pj4gdG8gcmV0dXJuIHRoZSBvcmlnaW5hbCBwdGUgdG8gaGVscCB0byBu
dWtlIGEgaHVnZXRsYiBwYWdlIHRhYmxlLg0KPj4+DQo+Pj4gU2lnbmVkLW9mZi1ieTogQmFvbGlu
IFdhbmcgPGJhb2xpbi53YW5nQGxpbnV4LmFsaWJhYmEuY29tPg0KPj4+IEFja2VkLWJ5OiBNaWtl
IEtyYXZldHogPG1pa2Uua3JhdmV0ekBvcmFjbGUuY29tPg0KPj4NCj4+IFJldmlld2VkLWJ5OiBN
dWNodW4gU29uZyA8c29uZ211Y2h1bkBieXRlZGFuY2UuY29tPg0KPiANCj4gVGhhbmtzIGZvciBy
ZXZpZXdpbmcuDQo+IA0KPj4NCj4+IEJ1dCBvbmUgbml0IGJlbG93Og0KPj4NCj4+IFsuLi5dDQo+
Pj4gZGlmZiAtLWdpdCBhL21tL2h1Z2V0bGIuYyBiL21tL2h1Z2V0bGIuYw0KPj4+IGluZGV4IDg2
MDVkN2UuLjYxYTIxYWYgMTAwNjQ0DQo+Pj4gLS0tIGEvbW0vaHVnZXRsYi5jDQo+Pj4gKysrIGIv
bW0vaHVnZXRsYi5jDQo+Pj4gQEAgLTUzNDIsNyArNTM0Miw3IEBAIHN0YXRpYyB2bV9mYXVsdF90
IGh1Z2V0bGJfd3Aoc3RydWN0IG1tX3N0cnVjdCANCj4+PiAqbW0sIHN0cnVjdCB2bV9hcmVhX3N0
cnVjdCAqdm1hLA0KPj4+IMKgwqDCoMKgwqDCoMKgwqDCoCBDbGVhckhQYWdlUmVzdG9yZVJlc2Vy
dmUobmV3X3BhZ2UpOw0KPj4+IMKgwqDCoMKgwqDCoMKgwqDCoCAvKiBCcmVhayBDT1cgb3IgdW5z
aGFyZSAqLw0KPj4+IC3CoMKgwqDCoMKgwqDCoCBodWdlX3B0ZXBfY2xlYXJfZmx1c2godm1hLCBo
YWRkciwgcHRlcCk7DQo+Pj4gK8KgwqDCoMKgwqDCoMKgICh2b2lkKWh1Z2VfcHRlcF9jbGVhcl9m
bHVzaCh2bWEsIGhhZGRyLCBwdGVwKTsNCj4+DQo+PiBXaHkgYWRkIGEgIih2b2lkKSIgaGVyZT8g
SXMgdGhlcmUgYW55IHdhcm5pbmcgaWYgbm8gIih2b2lkKSI/DQo+PiBJSVVDLCBJIHRoaW5rIHdl
IGNhbiByZW1vdmUgdGhpcywgcmlnaHQ/DQo+IA0KPiBJIGRpZCBub3QgbWVldCBhbnkgd2Fybmlu
ZyB3aXRob3V0IHRoZSBjYXN0aW5nLCBidXQgdGhpcyBpcyBwZXIgTWlrZSdzIA0KPiBjb21tZW50
WzFdIHRvIG1ha2UgdGhlIGNvZGUgY29uc2lzdGVudCB3aXRoIG90aGVyIGZ1bmN0aW9ucyBjYXN0
aW5nIHRvIA0KPiB2b2lkIHR5cGUgZXhwbGljaXRseSBpbiBodWdldGxiLmMgZmlsZS4NCj4gDQo+
IFsxXSANCj4gaHR0cHM6Ly9sb3JlLmtlcm5lbC5vcmcvYWxsLzQ5NWM0ZWJlLWE1YjQtYWZiNi00
Y2IwLTk1NmMxYjE4ZDBjY0BvcmFjbGUuY29tLyANCj4gDQoNCkFzIGZhciBhcyBJIHVuZGVyc3Rh
bmQsIE1pa2Ugc2FpZCB0aGF0IHlvdSBzaG91bGQgYmUgYWNjb21wYWduaWVkIHdpdGggYSANCmJp
ZyBmYXQgY29tbWVudCBleHBsYWluaW5nIHdoeSB3ZSBpZ25vcmUgdGhlIHJldHVybmVkIHZhbHVl
IGZyb20gDQpodWdlX3B0ZXBfY2xlYXJfZmx1c2goKS4NCg0KQnkgdGhlIHdheSBodWdlX3B0ZXBf
Y2xlYXJfZmx1c2goKSBpcyBub3QgZGVjbGFyZWQgJ211c3RfY2hlY2snIHNvIHRoaXMgDQpjYXN0
IGlzIGp1c3QgdmlzdWFsIHBvbHV0aW9uIGFuZCBzaG91bGQgYmUgcmVtb3ZlZC4NCg0KSW4gdGhl
IG1lYW50aW1lIHRoZSBjb21tZW50IHN1Z2dlc3RlZCBieSBNaWtlIHNob3VsZCBiZSBhZGRlZCBp
bnN0ZWFkLg0KDQpDaHJpc3RvcGhl
