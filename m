From: Alexandre Ghiti <alexghiti@rivosinc.com>
Date: Thu, 02 Mar 2023 09:35:29 +0000
Subject: [PATCH v4 14/24] arc: Remove empty <uapi/asm/setup.h>
Message-Id: <20230302093539.372962-15-alexghiti@rivosinc.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230302093539.372962-1-alexghiti@rivosinc.com>
In-Reply-To: <20230302093539.372962-1-alexghiti@rivosinc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Jonathan Corbet <corbet@lwn.net>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org
Cc: Palmer Dabbelt <palmer@rivosinc.com>, =?UTF-8?q?Philippe=20Mathieu-Daud=C3=A9?= <philmd@linaro.org>

RnJvbTogUGFsbWVyIERhYmJlbHQgPHBhbG1lckByaXZvc2luYy5jb20+CgpTaWduZWQtb2ZmLWJ5
OiBQYWxtZXIgRGFiYmVsdCA8cGFsbWVyQHJpdm9zaW5jLmNvbT4KUmV2aWV3ZWQtYnk6IFBoaWxp
cHBlIE1hdGhpZXUtRGF1ZMOpIDxwaGlsbWRAbGluYXJvLm9yZz4KLS0tCiBhcmNoL2FyYy9pbmNs
dWRlL2FzbS9zZXR1cC5oICAgICAgfCAxIC0KIGFyY2gvYXJjL2luY2x1ZGUvdWFwaS9hc20vc2V0
dXAuaCB8IDYgLS0tLS0tCiAyIGZpbGVzIGNoYW5nZWQsIDcgZGVsZXRpb25zKC0pCiBkZWxldGUg
bW9kZSAxMDA2NDQgYXJjaC9hcmMvaW5jbHVkZS91YXBpL2FzbS9zZXR1cC5oCgpkaWZmIC0tZ2l0
IGEvYXJjaC9hcmMvaW5jbHVkZS9hc20vc2V0dXAuaCBiL2FyY2gvYXJjL2luY2x1ZGUvYXNtL3Nl
dHVwLmgKaW5kZXggMDI4YThjZjc2MjA2Li5mZTQ1ZmY0NjgxYmMgMTAwNjQ0Ci0tLSBhL2FyY2gv
YXJjL2luY2x1ZGUvYXNtL3NldHVwLmgKKysrIGIvYXJjaC9hcmMvaW5jbHVkZS9hc20vc2V0dXAu
aApAQCAtNyw3ICs3LDYgQEAKIAogCiAjaW5jbHVkZSA8bGludXgvdHlwZXMuaD4KLSNpbmNsdWRl
IDx1YXBpL2FzbS9zZXR1cC5oPgogCiAjZGVmaW5lIENPTU1BTkRfTElORV9TSVpFIDI1NgogCmRp
ZmYgLS1naXQgYS9hcmNoL2FyYy9pbmNsdWRlL3VhcGkvYXNtL3NldHVwLmggYi9hcmNoL2FyYy9p
bmNsdWRlL3VhcGkvYXNtL3NldHVwLmgKZGVsZXRlZCBmaWxlIG1vZGUgMTAwNjQ0CmluZGV4IGE2
ZDRlNDQ5MzhiZS4uMDAwMDAwMDAwMDAwCi0tLSBhL2FyY2gvYXJjL2luY2x1ZGUvdWFwaS9hc20v
c2V0dXAuaAorKysgL2Rldi9udWxsCkBAIC0xLDYgKzAsMCBAQAotLyoKLSAqIHNldHVwLmggaXMg
cGFydCBvZiB1c2Vyc3BhY2UgaGVhZGVyIEFCSSBzbyBVQVBJIHNjcmlwdHMgaGF2ZSB0byBnZW5l
cmF0ZSBpdAotICogZXZlbiBpZiB0aGVyZSdzIG5vdGhpbmcgdG8gZXhwb3J0IC0gY2F1c2luZyBl
bXB0eSA8dWFwaS9hc20vc2V0dXAuaD4KLSAqIEhvd2V2ZXIgdG8gcHJldmVudCAicGF0Y2giIGZy
b20gZGlzY2FyZGluZyBpdCB3ZSBhZGQgdGhpcyBwbGFjZWhvbGRlcgotICogY29tbWVudAotICov
Ci0tIAoyLjM3LjIK
