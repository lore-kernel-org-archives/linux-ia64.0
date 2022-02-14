From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 14 Feb 2022 22:13:34 +0000
Subject: RE: [PATCH 04/14] x86: use more conventional access_ok() definition
Message-Id: <2dda07f893cb4ef9b5ea2265adccb98f@AcuMS.aculab.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220214163452.1568807-1-arnd@kernel.org>
 <20220214163452.1568807-5-arnd@kernel.org> <YgqLFYqIqkIsNC92@infradead.org>
 <CAK8P3a1F3JaYaJPy9bSCG1+YV6EN05PE0DbwpD_GT1qRwFSJ-w@mail.gmail.com>
 <CAHk-=whq6_Nh3cB3FieP481VcRyCu69X3=wO1yLHGmcZEj69SA@mail.gmail.com>
 <CAHk-=wgYu67OwP4LhcrPdDVxv2mOsx-Xsc2DKoVW6GZwKFtOYQ@mail.gmail.com>
In-Reply-To: <CAHk-=wgYu67OwP4LhcrPdDVxv2mOsx-Xsc2DKoVW6GZwKFtOYQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Linus Torvalds' <torvalds@linux-foundation.org>, Arnd Bergmann <arnd@kernel.org>
Cc: Mark Rutland <mark.rutland@arm.com>, Rich Felker <dalias@libc.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>, Will Deacon <will@kernel.org>, Ard Biesheuvel <ardb@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Brian Cain <bcain@codeaurora.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, Helge Deller <deller@gmx.de>, the arch/x86 maintainers <x86@kernel.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Christoph Hellwig <hch@infradead.org>, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, Arnd Bergmann <arnd@arndb.de>, Heiko Carstens <hca@linux.ibm.com>, linux-um <linux-um@lists.infradead.org>, Richard Weinberger <richard@nod.at>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Openrisc <openrisc@lists.librecores.org>, Greentime Hu <green.hu@gmail.com>, Stafford Horne <shorne@gmail.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Parisc List <linux-parisc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dinh Nguyen <dinguyen@kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, alpha <linux-alpha@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, David Miller <davem@davemloft.net>, Al Viro <viro@zeniv.linux.org.uk>

RnJvbTogTGludXMgVG9ydmFsZHMNCj4gU2VudDogMTQgRmVicnVhcnkgMjAyMiAyMDoyNA0KPiA+
DQo+ID4geDg2LTY0IGhhcyBhbHdheXMoKikgdXNlZCBUQVNLX1NJWkVfTUFYIGZvciBhY2Nlc3Nf
b2soKSwgYW5kIHRoZQ0KPiA+IGdldF91c2VyKCkgYXNzZW1ibGVyIGltcGxlbWVudGF0aW9uIGRv
ZXMgdGhlIHNhbWUuDQo+IA0KPiBTaWRlIG5vdGU6IHdlIGNvdWxkIGp1c3QgY2hlY2sgdGhlIHNp
Z24gYml0IGluc3RlYWQsIGFuZCBhdm9pZCBiaWcNCj4gY29uc3RhbnRzIHRoYXQgd2F5Lg0KDQpU
aGUgY2hlYXAgdGVzdCBmb3IgbW9zdCA2NGJpdCBpcyAoYWRkciB8IHNpemUpID4+IDYyICE9IDAu
DQoNCkkgZGlkIHNvbWUgdGVzdHMgbGFzdCB3ZWVrIGFuZCB0aGUgY29tcGlsZXJzIGNvcnJlY3Rs
eSBvcHRpbWlzZQ0Kb3V0IGNvbnN0YW50IHNpemUuDQoNCkRvZXNuJ3Qgc3BhcmM2NCBzdGlsbCBu
ZWVkIGEgd3JhcCB0ZXN0Pw0KT3IgaXMgdGhhdCBhc3N1bWVkIGJlY2F1c2UgdGhlcmUgaXMgYWx3
YXlzIGFuIHVubWFwcGVkIHBhZ2UNCmFuZCB0cmFuc2ZlciBhcmUgJ2FkZXF1YXRlbHknIGRvbmUg
b24gaW5jcmVhc2luZyBhZGRyZXNzZXM/DQoNCglEYXZpZA0KDQotDQpSZWdpc3RlcmVkIEFkZHJl
c3MgTGFrZXNpZGUsIEJyYW1sZXkgUm9hZCwgTW91bnQgRmFybSwgTWlsdG9uIEtleW5lcywgTUsx
IDFQVCwgVUsNClJlZ2lzdHJhdGlvbiBObzogMTM5NzM4NiAoV2FsZXMpDQo
