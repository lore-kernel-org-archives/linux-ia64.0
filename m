From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Date: Tue, 05 May 2020 18:07:46 +0000
Subject: Re: [PATCH v2 17/20] mm: free_area_init: allow defining max_zone_pfn in descending order
Message-Id: <88b9465b-6e6d-86ca-3776-ccb7a5b60b7f@synopsys.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200429121126.17989-1-rppt@kernel.org>
 <20200429121126.17989-18-rppt@kernel.org>
 <20200503174138.GA114085@roeck-us.net> <20200503184300.GA154219@roeck-us.net>
 <20200504153901.GM14260@kernel.org>
 <a0b20e15-fddb-aa9c-fd67-f1c8e735b4a4@synopsys.com>
 <20200505091946.GG342687@linux.ibm.com>
In-Reply-To: <20200505091946.GG342687@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Mike Rapoport <rppt@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Rich Felker <dalias@libc.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "x86@kernel.org" <x86@kernel.org>, Michal Hocko <mhocko@kernel.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, Ley Foon Tan <ley.foon.tan@intel.com>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, Greg Ungerer <gerg@linux-m68k.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

T24gNS81LzIwIDI6MTkgQU0sIE1pa2UgUmFwb3BvcnQgd3JvdGU6DQo+IEZyb20gdGhlIGNvZGUg
SSd2ZSBnb3QgdGhlIGltcHJlc3Npb24gdGhhdCBpdCBpcyBlaXRoZXIgb25lIG9mIHRoZW0uIEku
ZQ0KPiB0aGUgcGh5c2ljYWwgbWVtb3J5IGlzIGVpdGhlciBhdA0KPg0KPiAweDgwMDBfMDAwMCAt
IDxlbmQgb2YgRERSIDAgYmFuaz4NCj4gMHgwMDAwXzAwMDAgLSA8ZW5kIG9mIEREUiAxIGJhbms+
DQo+DQo+IG9yDQo+DQo+IDB4MF84MDAwXzAwMDAgLSA8ZW5kIG9mIEREUiAwIGJhbms+DQo+IDB4
MV8wMDAwXzAwMDAgLSA8ZW5kIG9mIEREUiAxIGJhbms+DQo+DQo+IElzIHRoaXMgcG9zc2libGUg
dG8gaGF2ZSBhIHN5c3RlbSB3aXRoIHRocmVlIGxpdmUgcmFuZ2VzPyBMaWtlDQo+DQo+IDB4MF8w
MDAwXzAwMDAgLSA8ZW5kIG9mIEREUiAxIGJhbms+DQo+IDB4MF84MDAwXzAwMDAgLSA8ZW5kIG9m
IEREUiAwIGJhbms+DQo+IDB4MV8wMDAwXzAwMDAgLSA8ZW5kIG9mIEREUiAyIGJhbms+DQoNCldl
IGRvbid0IGhhdmUgc3VjaCBhIHN5c3RlbSwgYnV0IGl0IGlzIGluZGVlZCBwb3NzaWJsZSBpbiB0
aGVvcnkuIFRoZSBxdWVzdGlvbiBpcw0KwqAtIENhbiBvdGhlciBhcmNoZXMgaGF2ZSBzdWNoIGEg
c2V0dXAgdG9vDQrCoC0gSXMgaXQgbm90IGJldHRlciB0byBoYXZlIHRoZSBjb3JlIHJldGFpbiB0
aGUgZmxleGliaWxpdHkganVzdCBpbiBjYXNlDQoNClRoeCwNCi1WaW5lZXQNCg=
