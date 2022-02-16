From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Wed, 16 Feb 2022 19:43:22 +0000
Subject: Re: [PATCH 08/14] arm64: simplify access_ok()
Message-Id: <07050857-c9d2-bab2-2191-8d244d6f7708@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220214163452.1568807-1-arnd@kernel.org>
 <20220214163452.1568807-9-arnd@kernel.org>
 <CAMj1kXHixUFjV=4m3tzfGz7AiRWc-VczymbKuZq7dyZZNuLKxQ@mail.gmail.com>
 <CAK8P3a2VfvDkueaJNTA9SiB+PFsi_Q17AX+aL46ueooW2ahmQw@mail.gmail.com>
In-Reply-To: <CAK8P3a2VfvDkueaJNTA9SiB+PFsi_Q17AX+aL46ueooW2ahmQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>, Ard Biesheuvel <ardb@kernel.org>
Cc: Mark Rutland <mark.rutland@arm.com>, Rich Felker <dalias@libc.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, "open list:MIPS" <linux-mips@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Guo Ren <guoren@kernel.org>, "open list:SPARC + UltraSPARC (sparc/sparc64)" <sparclinux@vger.kernel.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>, Will Deacon <will@kernel.org>, Christoph Hellwig <hch@lst.de>, linux-arch <linux-arch@vger.kernel.org>, "open list:S390" <linux-s390@vger.kernel.org>, Brian Cain <bcain@codeaurora.org>, Helge Deller <deller@gmx.de>, X86 ML <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, Robin Murphy <robin.murphy@arm.com>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, Arnd Bergmann <arnd@arndb.de>, Heiko Carstens <hca@linux.ibm.com>, alpha <linux-alpha@vger.kernel.org>, linux-um <linux-um@lists.infradead.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Openrisc <openrisc@lists.librecores.org>, Greentime Hu <green.hu@gmail.com>, Stafford Horne <shorne@gmail.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, Nick Hu <nickhu@andestech.com>, Max Filippov <jcmvbkbc@gmail.com>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dinh Nguyen <dinguyen@kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Richard Weinberger <richard@nod.at>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>

DQoNCkxlIDE1LzAyLzIwMjIgw6AgMTA6MTIsIEFybmQgQmVyZ21hbm4gYSDDqWNyaXTCoDoNCj4g
T24gVHVlLCBGZWIgMTUsIDIwMjIgYXQgOToxNyBBTSBBcmQgQmllc2hldXZlbCA8YXJkYkBrZXJu
ZWwub3JnPiB3cm90ZToNCj4+IE9uIE1vbiwgMTQgRmViIDIwMjIgYXQgMTc6MzcsIEFybmQgQmVy
Z21hbm4gPGFybmRAa2VybmVsLm9yZz4gd3JvdGU6DQo+Pj4gRnJvbTogQXJuZCBCZXJnbWFubiA8
YXJuZEBhcm5kYi5kZT4NCj4+Pg0KPj4NCj4+IFdpdGggc2V0X2ZzKCkgb3V0IG9mIHRoZSBwaWN0
dXJlLCB3b3VsZG4ndCBpdCBiZSBzdWZmaWNpZW50IHRvIGNoZWNrDQo+PiB0aGF0IGJpdCAjNTUg
aXMgY2xlYXI/ICh0aGUgYml0IHRoYXQgc2VsZWN0cyBiZXR3ZWVuIFRUQlIwIGFuZCBUVEJSMSkN
Cj4+IFRoYXQgd291bGQgYWxzbyByZW1vdmUgdGhlIG5lZWQgdG8gc3RyaXAgdGhlIHRhZyBmcm9t
IHRoZSBhZGRyZXNzLg0KPj4NCj4+IFNvbWV0aGluZyBsaWtlDQo+Pg0KPj4gICAgICBhc20gZ290
bygidGJueiAgJTAsICM1NSwgJTIgICAgIFxuIg0KPj4gICAgICAgICAgICAgICAidGJueiAgJTEs
ICM1NSwgJTIgICAgIFxuIg0KPj4gICAgICAgICAgICAgICA6OiAiciIoYWRkciksICJyIihhZGRy
ICsgc2l6ZSAtIDEpIDo6IG5vdG9rKTsNCj4+ICAgICAgcmV0dXJuIDE7DQo+PiBub3RvazoNCj4+
ICAgICAgcmV0dXJuIDA7DQo+Pg0KPj4gd2l0aCBhbiBhZGRpdGlvbmFsIHNhbml0eSBjaGVjayBv
biB0aGUgc2l6ZSB3aGljaCB0aGUgY29tcGlsZXIgY291bGQNCj4+IGVsaW1pbmF0ZSBmb3IgY29t
cGlsZS10aW1lIGNvbnN0YW50IHZhbHVlcy4NCj4gDQo+IFRoYXQgc2hvdWxkIHdvcmssIGJ1dCBJ
IGRvbid0IHNlZSBpdCBhcyBhIGNsZWFyIGVub3VnaCBhZHZhbnRhZ2UgdG8NCj4gaGF2ZSBhIGN1
c3RvbSBpbXBsZW1lbnRhdGlvbi4gRm9yIHRoZSBjb25zdGFudC1zaXplIGNhc2UsIGl0IHByb2Jh
Ymx5DQo+IGlzbid0IGJldHRlciB0aGFuIGEgY29tcGlsZXItc2NoZWR1bGVkIGNvbXBhcmlzb24g
YWdhaW5zdCBhDQo+IGNvbnN0YW50IGxpbWl0LCBidXQgaXQgZG9lcyBodXJ0IG1haW50YWluYWJp
bGl0eSB3aGVuIHRoZSBuZXh0IHBlcnNvbg0KPiB3YW50cyB0byBjaGFuZ2UgdGhlIGJlaGF2aW9y
IG9mIGFjY2Vzc19vaygpIGdsb2JhbGx5Lg0KPiANCj4gSWYgd2Ugd2FudCB0byBnZXQgaW50byBt
aWNyby1vcHRpbWl6aW5nIHVhY2Nlc3MsIEkgdGhpbmsgYSBiZXR0ZXIgdGFyZ2V0DQo+IHdvdWxk
IGJlIGEgQ09ORklHX0NDX0hBU19BU01fR09UT19PVVRQVVQgdmVyc2lvbg0KPiBvZiBfX2dldF91
c2VyKCkvX19wdXRfdXNlciBhcyB3ZSBoYXZlIG9uIHg4NiBhbmQgcG93ZXJwYy4NCj4gDQoNClRo
ZXJlIGlzIGFsc28gdGhlIHVzZXIgYmxvY2sgYWNjZXNzZXMgd2l0aCANCnVzZXJfYWNjZXNzX2Jl
Z2luKCkvdXNlcl9hY2Nlc3NfZW5kKCkgdG9nZXRoZXIgd2l0aCB1bnNhZmVfcHV0X3VzZXIoKSAN
CmFuZCB1bnNhZmVfZ2V0X3VzZXIoKSB3aGljaCBhbGxvd2VkIHVzIHRvIG9wdGltaXNlIHVzZXIg
YWNjZXNzZXMgb24gDQpwb3dlcnBjLCBlc3BlY2lhbGx5IGluIHRoZSBzaWduYWwgY29kZS4NCg0K
Q2hyaXN0b3BoZQ=
