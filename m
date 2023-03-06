From: Alexandre Ghiti <alexghiti@rivosinc.com>
Date: Mon, 06 Mar 2023 10:04:50 +0000
Subject: [PATCH v5 08/26] parisc: Remove COMMAND_LINE_SIZE from uapi
Message-Id: <20230306100508.1171812-9-alexghiti@rivosinc.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230306100508.1171812-1-alexghiti@rivosinc.com>
In-Reply-To: <20230306100508.1171812-1-alexghiti@rivosinc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Greg KH <gregkh@linuxfoundation.org>, Jonathan Corbet <corbet@lwn.net>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org
Cc: Palmer Dabbelt <palmer@rivosinc.com>, Alexandre Ghiti <alexghiti@rivosinc.com>, =?UTF-8?q?Philippe=20Mathieu-Daud=C3=A9?= <philmd@linaro.org>

RnJvbTogUGFsbWVyIERhYmJlbHQgPHBhbG1lckByaXZvc2luYy5jb20+CgpBcyBmYXIgYXMgSSBj
YW4gdGVsbCB0aGlzIGlzIG5vdCB1c2VkIGJ5IHVzZXJzcGFjZSBhbmQgdGh1cyBzaG91bGQgbm90
CmJlIHBhcnQgb2YgdGhlIHVzZXItdmlzaWJsZSBBUEkuCgpTaWduZWQtb2ZmLWJ5OiBQYWxtZXIg
RGFiYmVsdCA8cGFsbWVyQHJpdm9zaW5jLmNvbT4KU2lnbmVkLW9mZi1ieTogQWxleGFuZHJlIEdo
aXRpIDxhbGV4Z2hpdGlAcml2b3NpbmMuY29tPgpSZXZpZXdlZC1ieTogUGhpbGlwcGUgTWF0aGll
dS1EYXVkw6kgPHBoaWxtZEBsaW5hcm8ub3JnPgpBY2tlZC1ieTogSGVsZ2UgRGVsbGVyIDxkZWxs
ZXJAZ214LmRlPgotLS0KIGFyY2gvcGFyaXNjL2luY2x1ZGUvYXNtL3NldHVwLmggICAgICB8IDcg
KysrKysrKwogYXJjaC9wYXJpc2MvaW5jbHVkZS91YXBpL2FzbS9zZXR1cC5oIHwgMiAtLQogMiBm
aWxlcyBjaGFuZ2VkLCA3IGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCiBjcmVhdGUgbW9k
ZSAxMDA2NDQgYXJjaC9wYXJpc2MvaW5jbHVkZS9hc20vc2V0dXAuaAoKZGlmZiAtLWdpdCBhL2Fy
Y2gvcGFyaXNjL2luY2x1ZGUvYXNtL3NldHVwLmggYi9hcmNoL3BhcmlzYy9pbmNsdWRlL2FzbS9z
ZXR1cC5oCm5ldyBmaWxlIG1vZGUgMTAwNjQ0CmluZGV4IDAwMDAwMDAwMDAwMC4uNDRlMWM0MjI0
NGJiCi0tLSAvZGV2L251bGwKKysrIGIvYXJjaC9wYXJpc2MvaW5jbHVkZS9hc20vc2V0dXAuaApA
QCAtMCwwICsxLDcgQEAKKy8qIFNQRFgtTGljZW5zZS1JZGVudGlmaWVyOiBHUEwtMi4wICovCisj
aWZuZGVmIF9QQVJJU0NfU0VUVVBfSAorI2RlZmluZSBfUEFSSVNDX1NFVFVQX0gKKworI2RlZmlu
ZSBDT01NQU5EX0xJTkVfU0laRQkxMDI0CisKKyNlbmRpZiAvKiBfUEFSSVNDX1NFVFVQX0ggKi8K
ZGlmZiAtLWdpdCBhL2FyY2gvcGFyaXNjL2luY2x1ZGUvdWFwaS9hc20vc2V0dXAuaCBiL2FyY2gv
cGFyaXNjL2luY2x1ZGUvdWFwaS9hc20vc2V0dXAuaAppbmRleCA3OGIyZjRlYzdkNjUuLmJmYWQ4
OTQyOGU0NyAxMDA2NDQKLS0tIGEvYXJjaC9wYXJpc2MvaW5jbHVkZS91YXBpL2FzbS9zZXR1cC5o
CisrKyBiL2FyY2gvcGFyaXNjL2luY2x1ZGUvdWFwaS9hc20vc2V0dXAuaApAQCAtMiw2ICsyLDQg
QEAKICNpZm5kZWYgX1BBUklTQ19TRVRVUF9ICiAjZGVmaW5lIF9QQVJJU0NfU0VUVVBfSAogCi0j
ZGVmaW5lIENPTU1BTkRfTElORV9TSVpFCTEwMjQKLQogI2VuZGlmIC8qIF9QQVJJU0NfU0VUVVBf
SCAqLwotLSAKMi4zNy4yCg==
