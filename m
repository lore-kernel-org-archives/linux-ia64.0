From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Date: Thu, 07 May 2020 21:21:03 +0000
Subject: Re: [PATCH v2 17/20] mm: free_area_init: allow defining max_zone_pfn in descending order
Message-Id: <80b0c001-ea48-f5a2-e0de-19b2cc6ec2ce@synopsys.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200429121126.17989-1-rppt@kernel.org>
 <20200429121126.17989-18-rppt@kernel.org>
 <20200503174138.GA114085@roeck-us.net> <20200503184300.GA154219@roeck-us.net>
 <20200504153901.GM14260@kernel.org>
 <a0b20e15-fddb-aa9c-fd67-f1c8e735b4a4@synopsys.com>
 <20200505091946.GG342687@linux.ibm.com>
 <88b9465b-6e6d-86ca-3776-ccb7a5b60b7f@synopsys.com>
 <20200505201522.GA683243@linux.ibm.com>
 <20200507205900.GH683243@linux.ibm.com>
In-Reply-To: <20200507205900.GH683243@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rich Felker <dalias@libc.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, Greg Ungerer <gerg@linux-m68k.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-c6x-dev@linux-c6x.org" <linux-c6x-dev@li>

T24gNS83LzIwIDE6NTkgUE0sIE1pa2UgUmFwb3BvcnQgd3JvdGU6DQo+IE9uIFR1ZSwgTWF5IDA1
LCAyMDIwIGF0IDExOjE1OjIyUE0gKzAzMDAsIE1pa2UgUmFwb3BvcnQgd3JvdGU6DQo+PiBPbiBU
dWUsIE1heSAwNSwgMjAyMCBhdCAwNjowNzo0NlBNICswMDAwLCBWaW5lZXQgR3VwdGEgd3JvdGU6
DQo+Pj4gT24gNS81LzIwIDI6MTkgQU0sIE1pa2UgUmFwb3BvcnQgd3JvdGU6DQo+Pj4gwqAtIElz
IGl0IG5vdCBiZXR0ZXIgdG8gaGF2ZSB0aGUgY29yZSByZXRhaW4gdGhlIGZsZXhpYmlsaXR5IGp1
c3QgaW4gY2FzZQ0KPj4gSWYgdGhlIHJlcXVpcmVtZW50IHRvIGhhdmUgc3VwcG9ydCBmb3IgMy1i
YW5rcyBpcyBhIHRoZW9yZXRpY2FsDQo+PiBwb3NzaWJpbGl0eSwgSSB3b3VsZCBwcmVmZXIgdG8g
YWRqdXN0IEFSQydzIHZlcnNpb24gb2YNCj4+IGFyY2hfaGFzX2Rlc2NlbmRpbmdfbWF4X3pvbmVf
cGZucygpIHRvIGNvcGUgd2l0aCBlaXRoZXIgb2YgMi1iYW5rcw0KPj4gY29uZmlndXJhdGlvbiAo
UEFFNDAgYW5kIG5vbi1QQUU0MCkgYW5kIGRlYWwgd2l0aCB0aGUgdGhpcmQgYmFuayB3aGVuL2lm
DQo+PiBpdCBhY3R1YWxseSBtYXRlcmlhbGl6ZXMuDQoNCkZhaXIgZW5vdWdoLg0KDQo+IFRoZSBm
aXggYmVsb3cgc2hvdWxkIHRha2UgY2FyZSBvZiBhbnkgMi1iYW5rIGNvbmZpZ3VyYXRpb25zLiAN
Cj4gVGhpcyBpcyB2cy4gY3VycmVudCBtbW90bS4NCj4NCj4gRnJvbSBlYjgxMjRmYjM1ODQ2MDdk
MTAzNmI3YWUwMGM4MDkyYWU0M2U0ODBkIE1vbiBTZXAgMTcgMDA6MDA6MDAgMjAwMQ0KPiBGcm9t
OiBNaWtlIFJhcG9wb3J0IDxycHB0QGxpbnV4LmlibS5jb20+DQo+IERhdGU6IFRodSwgNyBNYXkg
MjAyMCAyMzo0NDoxNSArMDMwMA0KPiBTdWJqZWN0OiBbUEFUQ0hdIGFyYzogZnJlZV9hcmVhX2lu
aXQoKTogdGFrZSBpbnRvIGFjY291bnQgUEFFNDAgbW9kZQ0KPg0KPiBUaGUgYXJjaF9oYXNfZGVz
Y2VuZGluZ19tYXhfem9uZV9wZm5zKCkgZG9lcyBub3QgdGFrZSBpbnRvIGFjY291bnQgcGh5c2lj
YWwNCj4gbWVtb3J5IGxheW91dCBmb3IgUEFFNDAgY29uZmlndXJhdGlvbi4NCj4gV2l0aCBQQUU0
MCBlbmFibGVkLCB0aGUgSElHSE1FTSBpcyBhY3R1YWxseSBoaWdoZXIgdGhhbiBOT1JNQUwgYW5k
DQo+IGFyY2hfaGFzX2Rlc2NlbmRpbmdfbWF4X3pvbmVfcGZucygpIHNob3VsZCByZXR1cm4gZmFs
c2UgaW4gdGhpcyBjYXNlLg0KPg0KPiBTaWduZWQtb2ZmLWJ5OiBNaWtlIFJhcG9wb3J0IDxycHB0
QGxpbnV4LmlibS5jb20+DQoNCkxHVE0uDQoNCkFja2VkLWJ5OiBWaW5lZXQgR3VwdGEgPHZndXB0
YUBzeW5vcHN5cy5jb20+DQoNClRoeCwNCg0KPiAtLS0NCj4gIGFyY2gvYXJjL21tL2luaXQuYyB8
IDIgKy0NCj4gIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQ0K
Pg0KPiBkaWZmIC0tZ2l0IGEvYXJjaC9hcmMvbW0vaW5pdC5jIGIvYXJjaC9hcmMvbW0vaW5pdC5j
DQo+IGluZGV4IDM4Njk1OWJhYzNkMi4uZTdiZGMyYWMxYzg3IDEwMDY0NA0KPiAtLS0gYS9hcmNo
L2FyYy9tbS9pbml0LmMNCj4gKysrIGIvYXJjaC9hcmMvbW0vaW5pdC5jDQo+IEBAIC03OSw3ICs3
OSw3IEBAIHZvaWQgX19pbml0IGVhcmx5X2luaXRfZHRfYWRkX21lbW9yeV9hcmNoKHU2NCBiYXNl
LCB1NjQgc2l6ZSkNCj4gIA0KPiAgYm9vbCBhcmNoX2hhc19kZXNjZW5kaW5nX21heF96b25lX3Bm
bnModm9pZCkNCj4gIHsNCj4gLQlyZXR1cm4gdHJ1ZTsNCj4gKwlyZXR1cm4gIUlTX0VOQUJMRUQo
Q09ORklHX0FSQ19IQVNfUEFFNDApOw0KPiAgfQ0KPiAgDQo+ICAvKg0KDQo
