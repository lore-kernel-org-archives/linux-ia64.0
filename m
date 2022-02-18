From: David Laight <David.Laight@ACULAB.COM>
Date: Fri, 18 Feb 2022 09:30:32 +0000
Subject: RE: [PATCH v2 13/18] uaccess: generalize access_ok()
Message-Id: <93a1ee797e9d4f789dff85a3c0f0c232@AcuMS.aculab.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-1-arnd@kernel.org>
 <20220216131332.1489939-14-arnd@kernel.org>
 <CALCETrVOvYPN4_6hS8wpm2v9bGZupZ5x4=vZAseG57OUgvLGfw@mail.gmail.com>
In-Reply-To: <CALCETrVOvYPN4_6hS8wpm2v9bGZupZ5x4=vZAseG57OUgvLGfw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Andy Lutomirski' <luto@amacapital.net>, Arnd Bergmann <arnd@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "will@kernel.org" <will@kernel.org>, "guoren@kernel.org" <guoren@kernel.org>, "bcain@codeaurora.org" <bcain@codeaurora.org>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "monstr@monstr.eu" <monstr@monstr.eu>, "tsbogend@alpha.franken.de" <tsbogend@alpha.franken.de>, "nickhu@andestech.com" <nickhu@andestech.com>, "green.hu@gmail.com" <green.hu@gmail.com>, "dinguyen@kernel.org" <dinguyen@kernel.org>, "shorne@gmail.com" <shorne@gmail.com>, "deller@gmx.de" <deller@gmx.de>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, "peterz@infradead.org" <peterz@infradead.org>, "mingo@redhat.com" <mingo@redhat.com>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "hca@linux.ibm.com" <hca@linux.ibm.com>, "dalias@libc.org" <dalias@libc.org>, "davem@davemloft.net" <davem@davemloft.net>, "richard@nod.at" <richard@nod.at>, "x86@kernel.org" <x86@kernel.org>, "jcmvbkbc@gmail.com" <jcmvbkbc@gmail.com>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "ardb@kernel.org" <ardb@kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>

RnJvbTogQW5keSBMdXRvbWlyc2tpDQo+IFNlbnQ6IDE3IEZlYnJ1YXJ5IDIwMjIgMTk6MTUNCi4u
Lg0KPiBUaGlzIGlzbid0IGFjdHVhbGx5IG9wdGltYWwuICBPbiB4ODYsIFRBU0tfU0laRV9NQVgg
aXMgYSBiaXphcnJlDQo+IGNvbnN0YW50IHRoYXQgaGFzIGEgdmVyeSBzcGVjaWZpYyB2YWx1ZSB0
byB3b3JrIGFyb3VuZCBhIGJ1Z15XZGVzaWduDQo+IGVycm9yXldmZWF0dXJlIG9mIEludGVsIENQ
VXMuICBUQVNLX1NJWkVfTUFYIGlzIHRoZSBtYXhpbXVtIGFkZHJlc3MgYXQNCj4gd2hpY2ggdXNl
cnNwYWNlIGlzIHBlcm1pdHRlZCB0byBhbGxvY2F0ZSBtZW1vcnksIGJ1dCB0aGVyZSBpcyBhIGh1
Z2UNCj4gZ2FwIGJldHdlZW4gdXNlciBhbmQga2VybmVsIGFkZHJlc3NlcywgYW5kIGFueSB2YWx1
ZSBpbiB0aGUgZ2FwIHdvdWxkDQo+IGJlIGFkZXF1YXRlIGZvciB0aGUgY29tcGFyaXNvbi4gIElm
IHdlIHdhbnRlZCB0byBvcHRpbWl6ZSB0aGlzLCBzaW1wbHkNCj4gY2hlY2tpbmcgdGhlIGhpZ2gg
Yml0ICh3aGljaCB4ODYgY2FuIGRvIHdpdGhvdXQgYW55IGltbWVkaWF0ZQ0KPiBjb25zdGFudHMg
YXQgYWxsKSB3b3VsZCBiZSBzdWZmaWNpZW50IGFuZCwgZm9yIGFuIGFjY2VzcyBrbm93biB0byBm
aXQNCj4gaW4gMzIgYml0cywgb25lIGNvdWxkIGdldCBldmVuIGZhbmNpZXIgYW5kIGNvbXBsZXRl
bHkgaWdub3JlIHRoZSBzaXplDQo+IG9mIHRoZSBhY2Nlc3MuICAoRm9yIGFjY2Vzc2VzIG5vdCBr
bm93biB0byBmaXQgaW4gMzIgYml0cywgSSBzdXNwZWN0DQo+IHNvbWUgY3JlYXRpdml0eSBjb3Vs
ZCBzdGlsbCBjb21lIHVwIHdpdGggYSBjb25zdHJ1Y3Rpb24gdGhhdCdzDQo+IHN1YnN0YW50aWFs
bHkgZmFzdGVyIHRoYW4gdGhlIG9uZSBpbiB5b3VyIHBhdGNoLikNCj4gDQo+IFNvIHRoZXJlJ3Mg
cGxlbnR5IG9mIHJvb20gZm9yIG9wdGltaXphdGlvbiBoZXJlLg0KPiANCj4gKFRoaXMgaXMgbm90
IGluIGFueSByZXNwZWN0IGEgTkFLIC0tIGl0J3MganVzdCBhbiBvYnNlcnZhdGlvbiB0aGF0DQo+
IHRoaXMgY291bGQgYmUgZXZlbiBiZXR0ZXIuKQ0KDQpGb3IgNjRiaXQgYXJjaCB0aGF0IHVzZSB0
aGUgdG9wIGJpdCB0byBzZXBhcmF0ZSB1c2VyL2tlcm5lbA0KeW91IGNhbiB0ZXN0ICcoYWRkciB8
IHNpemUpID4+IDYyKScuDQpUaGUgY29tcGlsZXIgb3B0aW1pc2VzIG91dCBjb25zdGFudCBzaXpl
cy4NCg0KVGhpcyBoYXMgYWxsIGJlZW4gbWVudGlvbmVkIGEgbG90IG9mIHRpbWVzLg0KWW91IGRv
IGdldCBkaWZmZXJlbnQgZmF1bHQgdHlwZXMuDQoNCk9UT0ggYW4gZXhwbGljaXQgY2hlY2sgZm9y
IGNvbnN0YW50IHNpemUgKGxlc3MgdGhhbiBzb21ldGhpbmcgYmlnKQ0KY2FuIHVzZSB0aGUgY2hl
YXBlciB0ZXN0IG9mIHRoZSBzaWduIGJpdC4NCkJpZyBjb25zdGFudCBzaXplcyBjb3VsZCBiZSBj
b21waWxlIHRpbWUgZXJyb3JzLg0KDQoJRGF2aWQNCg0KLQ0KUmVnaXN0ZXJlZCBBZGRyZXNzIExh
a2VzaWRlLCBCcmFtbGV5IFJvYWQsIE1vdW50IEZhcm0sIE1pbHRvbiBLZXluZXMsIE1LMSAxUFQs
IFVLDQpSZWdpc3RyYXRpb24gTm86IDEzOTczODYgKFdhbGVzKQ0K
