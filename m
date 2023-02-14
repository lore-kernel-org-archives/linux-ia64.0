From: =?UTF-8?Q?Philippe_Mathieu-Daud=c3=a9?= <philmd@linaro.org>
Date: Tue, 14 Feb 2023 09:05:59 +0000
Subject: Re: [PATCH v3 14/24] arc: Remove empty <uapi/asm/setup.h>
Message-Id: <84bde3ef-4701-431c-3ae0-3f5793e1e13a@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230214074925.228106-1-alexghiti@rivosinc.com>
 <20230214074925.228106-15-alexghiti@rivosinc.com>
In-Reply-To: <20230214074925.228106-15-alexghiti@rivosinc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Alexandre Ghiti <alexghiti@rivosinc.com>, Jonathan Corbet <corbet@lwn.net>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org
Cc: Palmer Dabbelt <palmer@rivosinc.com>

T24gMTQvMi8yMyAwODo0OSwgQWxleGFuZHJlIEdoaXRpIHdyb3RlOgo+IEZyb206IFBhbG1lciBE
YWJiZWx0IDxwYWxtZXJAcml2b3NpbmMuY29tPgo+IAo+IFNpZ25lZC1vZmYtYnk6IFBhbG1lciBE
YWJiZWx0IDxwYWxtZXJAcml2b3NpbmMuY29tPgo+IC0tLQo+ICAgYXJjaC9hcmMvaW5jbHVkZS9h
c20vc2V0dXAuaCAgICAgIHwgMSAtCj4gICBhcmNoL2FyYy9pbmNsdWRlL3VhcGkvYXNtL3NldHVw
LmggfCA2IC0tLS0tLQo+ICAgMiBmaWxlcyBjaGFuZ2VkLCA3IGRlbGV0aW9ucygtKQo+ICAgZGVs
ZXRlIG1vZGUgMTAwNjQ0IGFyY2gvYXJjL2luY2x1ZGUvdWFwaS9hc20vc2V0dXAuaAoKUmV2aWV3
ZWQtYnk6IFBoaWxpcHBlIE1hdGhpZXUtRGF1ZMOpIDxwaGlsbWRAbGluYXJvLm9yZz4K
