From: =?UTF-8?Q?Philippe_Mathieu-Daud=c3=a9?= <philmd@linaro.org>
Date: Tue, 14 Feb 2023 09:08:15 +0000
Subject: Re: [PATCH v3 08/24] parisc: Remove COMMAND_LINE_SIZE from uapi
Message-Id: <f327ff48-cd50-4caa-1bea-f9906994e998@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230214074925.228106-1-alexghiti@rivosinc.com>
 <20230214074925.228106-9-alexghiti@rivosinc.com>
In-Reply-To: <20230214074925.228106-9-alexghiti@rivosinc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Alexandre Ghiti <alexghiti@rivosinc.com>, Jonathan Corbet <corbet@lwn.net>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org
Cc: Palmer Dabbelt <palmer@rivosinc.com>

T24gMTQvMi8yMyAwODo0OSwgQWxleGFuZHJlIEdoaXRpIHdyb3RlOgo+IEZyb206IFBhbG1lciBE
YWJiZWx0IDxwYWxtZXJAcml2b3NpbmMuY29tPgo+IAo+IEFzIGZhciBhcyBJIGNhbiB0ZWxsIHRo
aXMgaXMgbm90IHVzZWQgYnkgdXNlcnNwYWNlIGFuZCB0aHVzIHNob3VsZCBub3QKPiBiZSBwYXJ0
IG9mIHRoZSB1c2VyLXZpc2libGUgQVBJLgo+IAo+IFNpZ25lZC1vZmYtYnk6IFBhbG1lciBEYWJi
ZWx0IDxwYWxtZXJAcml2b3NpbmMuY29tPgo+IC0tLQo+ICAgYXJjaC9wYXJpc2MvaW5jbHVkZS9h
c20vc2V0dXAuaCAgICAgIHwgNyArKysrKysrCj4gICBhcmNoL3BhcmlzYy9pbmNsdWRlL3VhcGkv
YXNtL3NldHVwLmggfCAyIC0tCj4gICAyIGZpbGVzIGNoYW5nZWQsIDcgaW5zZXJ0aW9ucygrKSwg
MiBkZWxldGlvbnMoLSkKPiAgIGNyZWF0ZSBtb2RlIDEwMDY0NCBhcmNoL3BhcmlzYy9pbmNsdWRl
L2FzbS9zZXR1cC5oCgpSZXZpZXdlZC1ieTogUGhpbGlwcGUgTWF0aGlldS1EYXVkw6kgPHBoaWxt
ZEBsaW5hcm8ub3JnPgo=
