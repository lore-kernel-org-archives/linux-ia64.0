From: Alexandre Ghiti <alexghiti@rivosinc.com>
Date: Mon, 06 Mar 2023 10:04:49 +0000
Subject: [PATCH v5 07/26] mips: Remove COMMAND_LINE_SIZE from uapi
Message-Id: <20230306100508.1171812-8-alexghiti@rivosinc.com>
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
dS1EYXVkw6kgPHBoaWxtZEBsaW5hcm8ub3JnPgotLS0KIGFyY2gvbWlwcy9pbmNsdWRlL2FzbS9z
ZXR1cC5oICAgICAgfCAzICsrLQogYXJjaC9taXBzL2luY2x1ZGUvdWFwaS9hc20vc2V0dXAuaCB8
IDMgLS0tCiAyIGZpbGVzIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgNCBkZWxldGlvbnMoLSkK
CmRpZmYgLS1naXQgYS9hcmNoL21pcHMvaW5jbHVkZS9hc20vc2V0dXAuaCBiL2FyY2gvbWlwcy9p
bmNsdWRlL2FzbS9zZXR1cC5oCmluZGV4IDhjNTZiODYyZmQ5Yy4uYTEzYjkyNTliNDc2IDEwMDY0
NAotLS0gYS9hcmNoL21pcHMvaW5jbHVkZS9hc20vc2V0dXAuaAorKysgYi9hcmNoL21pcHMvaW5j
bHVkZS9hc20vc2V0dXAuaApAQCAtMyw3ICszLDggQEAKICNkZWZpbmUgX01JUFNfU0VUVVBfSAog
CiAjaW5jbHVkZSA8bGludXgvdHlwZXMuaD4KLSNpbmNsdWRlIDx1YXBpL2FzbS9zZXR1cC5oPgor
CisjZGVmaW5lIENPTU1BTkRfTElORV9TSVpFCTQwOTYKIAogZXh0ZXJuIHZvaWQgcHJvbV9wdXRj
aGFyKGNoYXIpOwogZXh0ZXJuIHZvaWQgc2V0dXBfZWFybHlfcHJpbnRrKHZvaWQpOwpkaWZmIC0t
Z2l0IGEvYXJjaC9taXBzL2luY2x1ZGUvdWFwaS9hc20vc2V0dXAuaCBiL2FyY2gvbWlwcy9pbmNs
dWRlL3VhcGkvYXNtL3NldHVwLmgKaW5kZXggN2Q0OGM0MzNiMGMyLi4xNTdjM2MzOTJmYjQgMTAw
NjQ0Ci0tLSBhL2FyY2gvbWlwcy9pbmNsdWRlL3VhcGkvYXNtL3NldHVwLmgKKysrIGIvYXJjaC9t
aXBzL2luY2x1ZGUvdWFwaS9hc20vc2V0dXAuaApAQCAtMiw3ICsyLDQgQEAKICNpZm5kZWYgX1VB
UElfTUlQU19TRVRVUF9ICiAjZGVmaW5lIF9VQVBJX01JUFNfU0VUVVBfSAogCi0jZGVmaW5lIENP
TU1BTkRfTElORV9TSVpFCTQwOTYKLQotCiAjZW5kaWYgLyogX1VBUElfTUlQU19TRVRVUF9IICov
Ci0tIAoyLjM3LjIK
