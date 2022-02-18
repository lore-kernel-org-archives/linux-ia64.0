From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Fri, 18 Feb 2022 10:01:32 +0000
Subject: Re: [PATCH v2 00/18] clean up asm/uaccess.h, kill set_fs for good
Message-Id: <c5710bc5-0440-b828-d91e-6961081573af@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-1-arnd@kernel.org>
 <00496df2-f9f2-2547-3ca3-7989e4713d6b@csgroup.eu>
 <Yg77bNZfNhSk0bVQ@zeniv-ca.linux.org.uk>
In-Reply-To: <Yg77bNZfNhSk0bVQ@zeniv-ca.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "dalias@libc.org" <dalias@libc.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "jcmvbkbc@gmail.com" <jcmvbkbc@gmail.com>, "guoren@kernel.org" <guoren@kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "will@kernel.org" <will@kernel.org>, "ardb@kernel.org" <ardb@kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "bcain@codeaurora.org" <bcain@codeaurora.org>, "deller@gmx.de" <deller@gmx.de>, "x86@kernel.org" <x86@kernel.org>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "hca@linux.ibm.com" <hca@linux.ibm.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "green.hu@gmail.com" <green.hu@gmail.com>, "shorne@gmail.com" <shorne@gmail.com>, "monstr@monstr.eu" <monstr@monstr.eu>, "tsbogend@alpha.franken.de" <tsbogend@alpha.franken.de>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "nickhu@andestech.com" <nickhu@andestech.com>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "dinguyen@kernel.org" <dinguyen@kernel.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "richard@nod.at" <richard@nod.at>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "davem@davemloft.net" <davem@davemloft.net>

DQoNCkxlIDE4LzAyLzIwMjIgw6AgMDI6NTAsIEFsIFZpcm8gYSDDqWNyaXTCoDoNCj4gT24gVGh1
LCBGZWIgMTcsIDIwMjIgYXQgMDc6MjA6MTFBTSArMDAwMCwgQ2hyaXN0b3BoZSBMZXJveSB3cm90
ZToNCj4gDQo+PiBBbmQgd2UgaGF2ZSBhbHNvDQo+PiB1c2VyX2FjY2Vzc19iZWdpbigpL3VzZXJf
cmVhZF9hY2Nlc3NfYmVnaW4oKS91c2VyX3dyaXRlX2FjY2Vzc19iZWdpbigpDQo+PiB3aGljaCBj
YWxsIGFjY2Vzc19vaygpIHRoZW4gZG8gdGhlIHJlYWwgd29yay4gQ291bGQgYmUgbWFkZSBnZW5l
cmljIHdpdGgNCj4+IGNhbGwgdG8gc29tZSBhcmNoIHNwZWNpZmljIF9fdXNlcl9hY2Nlc3NfYmVn
aW4oKSBhbmQgZnJpZW5kcyBhZnRlciB0aGUNCj4+IGFjY2Vzc19vaygpIGFuZCBldmVudHVhbGx5
IHRoZSBtaWdodF9mYXVsdCgpLg0KPiANCj4gTm90IGEgZ29vZCBpZGVhLCBjb25zaWRlcmluZyB0
aGUgZmFjdCB0aGF0IHdlIGRvIG5vdCB3YW50IHRvIGludml0ZQ0KPiB1c2VzIG9mICJmYXN0ZXIi
IHZhcmlhbnRzLi4uDQoNCkknbSBub3Qgc3VyZSBJIHVuZGVyc3RhbmQgeW91ciBjb25jZXJuLg0K
DQpUb2RheSBpbiBwb3dlcnBjIHdlIGhhdmU6DQoNCglzdGF0aWMgX19tdXN0X2NoZWNrIGlubGlu
ZSBib29sDQoJdXNlcl9yZWFkX2FjY2Vzc19iZWdpbihjb25zdCB2b2lkIF9fdXNlciAqcHRyLCBz
aXplX3QgbGVuKQ0KCXsNCgkJaWYgKHVubGlrZWx5KCFhY2Nlc3Nfb2socHRyLCBsZW4pKSkNCgkJ
CXJldHVybiBmYWxzZTsNCg0KCQltaWdodF9mYXVsdCgpOw0KDQoJCWFsbG93X3JlYWRfZnJvbV91
c2VyKHB0ciwgbGVuKTsNCgkJcmV0dXJuIHRydWU7DQoJfQ0KDQpXZSBjb3VsZCBpbnN0ZWFkIGhh
dmUgYSBnZW5lcmljDQoNCglzdGF0aWMgX19tdXN0X2NoZWNrIGlubGluZSBib29sDQoJdXNlcl9y
ZWFkX2FjY2Vzc19iZWdpbihjb25zdCB2b2lkIF9fdXNlciAqcHRyLCBzaXplX3QgbGVuKQ0KCXsN
CgkJaWYgKHVubGlrZWx5KCFhY2Nlc3Nfb2socHRyLCBsZW4pKSkNCgkJCXJldHVybiBmYWxzZTsN
Cg0KCQltaWdodF9mYXVsdCgpOw0KDQoJCXJldHVybiBhcmNoX3VzZXJfcmVhZF9hY2Nlc3NfYmVn
aW4ocHRyLCBsZW4pOw0KCX0NCg0KQW5kIHRoZW4gYSBwb3dlcnBjIHNwZWNpZmljDQoNCglzdGF0
aWMgX19tdXN0X2NoZWNrIF9fYWx3YXlzX2lubGluZSBib29sDQoJYXJjaF91c2VyX3JlYWRfYWNj
ZXNzX2JlZ2luKGNvbnN0IHZvaWQgX191c2VyICpwdHIsIHNpemVfdCBsZW4pDQoJew0KCQlhbGxv
d19yZWFkX2Zyb21fdXNlcihwdHIsIGxlbik7DQoJCXJldHVybiB0cnVlOw0KCX0NCgkjZGVmaW5l
IGFyY2hfdXNlcl9yZWFkX2FjY2Vzc19iZWdpbiBhcmNoX3VzZXJfcmVhZF9hY2Nlc3NfYmVnaW4N
Cg0KQW5kIGEgZ2VuZXJpYyBmYWxsYmFjayBmb3IgYXJjaF91c2VyX3JlYWRfYWNjZXNzX2JlZ2lu
KCkgdGhhdCBkb2VzIA0Kbm90aGluZyBhdCBhbGwuDQoNCkRvIHlvdSBtZWFuIHRoYXQgaW4gdGhh
dCBjYXNlIHBlb3BsZSBtaWdodCBiZSB0ZW1wdGVkIHRvIHVzZSANCmFyY2hfdXNlcl9yZWFkX2Fj
Y2Vzc19iZWdpbigpIGluc3RlYWQgb2YgdXNpbmcgdXNlcl9yZWFkX2FjY2Vzc19iZWdpbigpID8N
Cg0KSWYgdGhhdCdzIHRoZSBjYXNlIGlzbid0IGl0IHNvbWV0aGluZyB3ZSBjb3VsZCB2ZXJpZnkg
dmlhIGNoZWNrcGF0Y2gucGwgPw0KDQpUb2RheSBpdCBzZWVtcyB0byBiZSBwcm9ibGVtYXRpYyB0
aGF0IGZ1bmN0aW9ucyBpbiBhc20vdWFjY2Vzcy5oIHVzZSANCmFjY2Vzc19vaygpLiBTdWNoIGFu
IGFwcHJvYWNoIHdvdWxkIGFsbG93IHRvIGdldCByaWQgb2YgYWNjZXNzX29rKCkgdXNlIA0KaW4g
YXJjaGl0ZWN0dXJlJ3MgdWFjY2Vzcy5oDQoNCkNocmlzdG9waGU
