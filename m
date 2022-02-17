From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Thu, 17 Feb 2022 07:20:11 +0000
Subject: Re: [PATCH v2 00/18] clean up asm/uaccess.h, kill set_fs for good
Message-Id: <00496df2-f9f2-2547-3ca3-7989e4713d6b@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-1-arnd@kernel.org>
In-Reply-To: <20220216131332.1489939-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
Cc: "mark.rutland@arm.com" <mark.rutland@arm.com>, "dalias@libc.org" <dalias@libc.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "jcmvbkbc@gmail.com" <jcmvbkbc@gmail.com>, "guoren@kernel.org" <guoren@kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "will@kernel.org" <will@kernel.org>, "ardb@kernel.org" <ardb@kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "bcain@codeaurora.org" <bcain@codeaurora.org>, "deller@gmx.de" <deller@gmx.de>, "x86@kernel.org" <x86@kernel.org>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "hca@linux.ibm.com" <hca@linux.ibm.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "green.hu@gmail.com" <green.hu@gmail.com>, "shorne@gmail.com" <shorne@gmail.com>, "monstr@monstr.eu" <monstr@monstr.eu>, "tsbogend@alpha.franken.de" <tsbogend@alpha.franken.de>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "nickhu@andestech.com" <nickhu@andestech.com>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "dinguyen@kernel.org" <dinguyen@kernel.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "richard@nod.at" <richard@nod.at>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "davem@davemloft.net" <davem@davemloft.net>

DQoNCkxlIDE2LzAyLzIwMjIgw6AgMTQ6MTMsIEFybmQgQmVyZ21hbm4gYSDDqWNyaXTCoDoNCj4g
RnJvbTogQXJuZCBCZXJnbWFubiA8YXJuZEBhcm5kYi5kZT4NCj4gDQo+IENocmlzdG9waCBIZWxs
d2lnIGFuZCBhIGZldyBvdGhlcnMgc3BlbnQgYSBodWdlIGVmZm9ydCBvbiByZW1vdmluZw0KPiBz
ZXRfZnMoKSBmcm9tIG1vc3Qgb2YgdGhlIGltcG9ydGFudCBhcmNoaXRlY3R1cmVzLCBidXQgYWJv
dXQgaGFsZiB0aGUNCj4gb3RoZXIgYXJjaGl0ZWN0dXJlcyB3ZXJlIG5ldmVyIGNvbXBsZXRlZCBl
dmVuIHRob3VnaCBtb3N0IG9mIHRoZW0gZG9uJ3QNCj4gYWN0dWFsbHkgdXNlIHNldF9mcygpIGF0
IGFsbC4NCj4gDQo+IEkgZGlkIGEgcGF0Y2ggZm9yIG1pY3JvYmxhemUgYXQgc29tZSBwb2ludCwg
d2hpY2ggdHVybmVkIG91dCB0byBiZSBmYWlybHkNCj4gZ2VuZXJpYywgYW5kIG5vdyBwb3J0ZWQg
aXQgdG8gbW9zdCBvdGhlciBhcmNoaXRlY3R1cmVzLCB1c2luZyBuZXcgZ2VuZXJpYw0KPiBpbXBs
ZW1lbnRhdGlvbnMgb2YgYWNjZXNzX29rKCkgYW5kIF9fe2dldCxwdXR9X2tlcm5lbF9ub2NoZWNr
KCkuDQo+IA0KPiBUaHJlZSBhcmNoaXRlY3R1cmVzIChzcGFyYzY0LCBpYTY0LCBhbmQgc2gpIG5l
ZWRlZCBzb21lIGV4dHJhIHdvcmssDQo+IHdoaWNoIEkgYWxzbyBjb21wbGV0ZWQuDQo+IA0KPiBU
aGUgZmluYWwgc2VyaWVzIGNvbnRhaW5zIGV4dHJhIGNsZWFudXAgY2hhbmdlcyB0aGF0IHRvdWNo
IGFsbA0KPiBhcmNoaXRlY3R1cmVzLiBQbGVhc2UgcmV2aWV3IGFuZCB0ZXN0IHRoZXNlLCBzbyB3
ZSBjYW4gbWVyZ2UgdGhlbQ0KPiBmb3IgdjUuMTguDQoNCkFzIGEgZnVydGhlciBjbGVhbnVwLCBo
YXZlIHlvdSB0aG91Z2h0IGFib3V0IG1ha2luZyBhIGdlbmVyaWMgdmVyc2lvbiBvZiANCmNsZWFy
X3VzZXIoKSA/IE9uIGFsbW9zdCBhbGwgYXJjaGl0ZWN0dXJlcywgY2xlYXJfdXNlcigpIGRvZXMg
YW4gDQphY2Nlc3Nfb2soKSB0aGVuIGNhbGxzIF9fY2xlYXJfdXNlcigpIG9yIHNpbWlsYXIuDQoN
Ck1heWJlIGFsc28gdGhlIHNhbWUgd2l0aCBwdXRfdXNlcigpIGFuZCBnZXRfdXNlcigpID8gQWZ0
ZXIgYWxsIGl0IGlzIA0KanVzdCBhY2Nlc3Nfb2soKSBmb2xsb3dlZCBieSBfX3B1dF91c2VyKCkg
b3IgX19nZXRfdXNlcigpID8gSXQgc2VlbXMgDQptb3JlIHRyaWNreSB0aG91Z2gsIGFzIHNvbWUg
YXJjaGl0ZWN0dXJlcyBzZWVtcyB0byBoYXZlIGxlc3MgdHJpdmlhbCANCnN0dWZmIHRoZXJlLg0K
DQpJIGFsc28gc2VlIGFsbCBhcmNoaXRlY3R1cmVzIGhhdmUgYSBwcm90b3R5cGUgZm9yIHN0cm5j
cHlfZnJvbV91c2VyKCkgDQphbmQgc3Rybmxlbl91c2VyKCkuIENvdWxkIGJlIGEgY29tbW9uIHBy
b3RvdHlwZSBpbnN0ZWFkIHdoZW4gd2UgaGF2ZSANCkdFTkVSSUNfU1RSTkNQWV9GUk9NX1VTRVIg
LyBHRU5FUklDX1NUUk5MRU5fVVNFUg0KDQpBbmQgd2UgaGF2ZSBhbHNvIA0KdXNlcl9hY2Nlc3Nf
YmVnaW4oKS91c2VyX3JlYWRfYWNjZXNzX2JlZ2luKCkvdXNlcl93cml0ZV9hY2Nlc3NfYmVnaW4o
KSANCndoaWNoIGNhbGwgYWNjZXNzX29rKCkgdGhlbiBkbyB0aGUgcmVhbCB3b3JrLiBDb3VsZCBi
ZSBtYWRlIGdlbmVyaWMgd2l0aCANCmNhbGwgdG8gc29tZSBhcmNoIHNwZWNpZmljIF9fdXNlcl9h
Y2Nlc3NfYmVnaW4oKSBhbmQgZnJpZW5kcyBhZnRlciB0aGUgDQphY2Nlc3Nfb2soKSBhbmQgZXZl
bnR1YWxseSB0aGUgbWlnaHRfZmF1bHQoKS4NCg0KQ2hyaXN0b3BoZQ=
