From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Sat, 11 Dec 2021 19:32:16 +0000
Subject: Re: [PATCH v2 0/2] kdump: simplify code
Message-Id: <2dad13be-dcf7-3a96-c287-9452f0dc027e@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1639193588-7027-1-git-send-email-yangtiezhu@loongson.cn>
 <0c5cb37139af4f3e85cc2c5115d7d006@AcuMS.aculab.com>
In-Reply-To: <0c5cb37139af4f3e85cc2c5115d7d006@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>, 'Tiezhu Yang' <yangtiezhu@loongson.cn>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Xuefeng Li <lixuefeng@loongson.cn>, "x86@kernel.org" <x86@kernel.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

DQoNCkxlIDExLzEyLzIwMjEgw6AgMTg6NTMsIERhdmlkIExhaWdodCBhIMOpY3JpdMKgOg0KPiBG
cm9tOiBUaWV6aHUgWWFuZw0KPj4gU2VudDogMTEgRGVjZW1iZXIgMjAyMSAwMzozMw0KPj4NCj4+
IHYyOg0KPj4gICAgLS0gYWRkIGNvcHlfdG9fdXNlcl9vcl9rZXJuZWwoKSBpbiBsaWIvdXNlcmNv
cHkuYw0KPj4gICAgLS0gZGVmaW5lIHVzZXJidWYgYXMgYm9vbCB0eXBlDQo+IA0KPiBJbnN0ZWFk
IG9mIGhhdmluZyBhIGZsYWcgdG8gaW5kaWNhdGUgd2hldGhlciB0aGUgYnVmZmVyIGlzIHVzZXIg
b3Iga2VybmVsLA0KPiB3b3VsZCBpdCBiZSBiZXR0ZXIgdG8gaGF2ZSB0d28gc2VwYXJhdGUgYnVm
ZmVyIHBvaW50ZXJzLg0KPiBPbmUgZm9yIGEgdXNlciBzcGFjZSBidWZmZXIsIHRoZSBvdGhlciBm
b3IgYSBrZXJuZWwgc3BhY2UgYnVmZmVyLg0KPiBFeGFjdGx5IG9uZSBvZiB0aGUgYnVmZmVycyBz
aG91bGQgYWx3YXlzIGJlIE5VTEwuDQo+IA0KPiBUaGF0IHdheSB0aGUgZmxhZyBpcyBuZXZlciBp
bmNvcnJlY3RseSBzZXQuDQo+IA0KDQpJdCdzIGEgdmVyeSBnb29kIGlkZWEuDQoNCkkgd2FzIHdv
cnJpZWQgYWJvdXQgdGhlIGNhc3RzIGZvcmNpbmcgdGhlIF9fdXNlciBwcm9wZXJ0eSBhd2F5IGFu
ZCBiYWNrLiANCldpdGggdGhhdCBhcHByb2FjaCB3ZSB3aWxsIHByZXNlcnZlIHRoZSBfX3VzZXIg
dGFncyBvbiB1c2VyIGJ1ZmZlcnMgYW5kIA0KZW5hYmxlIHNwYXJzZSBjaGVja2luZy4NCg0KVGhl
IG9ubHkgbGl0dGxlIGRyYXdiYWNrIEkgc2VlIGlzIHRoYXQgYXBwYXJlbnRseSBHQ0MgZG9lc24n
dCBjb25zaWRlciANCnRoZSBOVUxMIHZhbHVlIGFzIGEgY29uc3RhbnQgYW5kIHRoZXJlZm9yZSBk
b2Vzbid0IHBlcmZvcm0gY29uc3RhbnQgDQpmb2xkaW5nIG9uIHBvaW50ZXJzLiBOb3Qgc3VyZSBp
ZiB0aGlzIGlzIGEgcHJvYmxlbSBoZXJlLg0KDQpDaHJpc3RvcGhl
