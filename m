From: Alexandre Ghiti <alexghiti@rivosinc.com>
Date: Mon, 06 Mar 2023 10:04:43 +0000
Subject: [PATCH v5 01/26] alpha: Remove COMMAND_LINE_SIZE from uapi
Message-Id: <20230306100508.1171812-2-alexghiti@rivosinc.com>
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
dS1EYXVkw6kgPHBoaWxtZEBsaW5hcm8ub3JnPgotLS0KIGFyY2gvYWxwaGEvaW5jbHVkZS9hc20v
c2V0dXAuaCAgICAgIHwgNCArKy0tCiBhcmNoL2FscGhhL2luY2x1ZGUvdWFwaS9hc20vc2V0dXAu
aCB8IDIgLS0KIDIgZmlsZXMgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCA0IGRlbGV0aW9ucygt
KQoKZGlmZiAtLWdpdCBhL2FyY2gvYWxwaGEvaW5jbHVkZS9hc20vc2V0dXAuaCBiL2FyY2gvYWxw
aGEvaW5jbHVkZS9hc20vc2V0dXAuaAppbmRleCAyNjJhYWI5OWUzOTEuLmVhMDhjYTQ1ZWZhOCAx
MDA2NDQKLS0tIGEvYXJjaC9hbHBoYS9pbmNsdWRlL2FzbS9zZXR1cC5oCisrKyBiL2FyY2gvYWxw
aGEvaW5jbHVkZS9hc20vc2V0dXAuaApAQCAtMiw4ICsyLDYgQEAKICNpZm5kZWYgX19BTFBIQV9T
RVRVUF9ICiAjZGVmaW5lIF9fQUxQSEFfU0VUVVBfSAogCi0jaW5jbHVkZSA8dWFwaS9hc20vc2V0
dXAuaD4KLQogLyoKICAqIFdlIGxlYXZlIG9uZSBwYWdlIGZvciB0aGUgaW5pdGlhbCBzdGFjayBw
YWdlLCBhbmQgb25lIHBhZ2UgZm9yCiAgKiB0aGUgaW5pdGlhbCBwcm9jZXNzIHN0cnVjdHVyZS4g
QWxzbywgdGhlIGNvbnNvbGUgZWF0cyAzIE1CIGZvcgpAQCAtMTQsNiArMTIsOCBAQAogLyogUmVt
b3ZlIHdoZW4gb2ZmaWNpYWwgTUlMTyBzb3VyY2VzIGhhdmUgRUxGIHN1cHBvcnQ6ICovCiAjZGVm
aW5lIEJPT1RfU0laRQkoMTYqMTAyNCkKIAorI2RlZmluZSBDT01NQU5EX0xJTkVfU0laRQkyNTYK
KwogI2lmZGVmIENPTkZJR19BTFBIQV9MRUdBQ1lfU1RBUlRfQUREUkVTUwogI2RlZmluZSBLRVJO
RUxfU1RBUlRfUEhZUwkweDMwMDAwMCAvKiBPbGQgYm9vdGxvYWRlcnMgaGFyZGNvZGVkIHRoaXMu
ICAqLwogI2Vsc2UKZGlmZiAtLWdpdCBhL2FyY2gvYWxwaGEvaW5jbHVkZS91YXBpL2FzbS9zZXR1
cC5oIGIvYXJjaC9hbHBoYS9pbmNsdWRlL3VhcGkvYXNtL3NldHVwLmgKaW5kZXggZjg4MWVhNTk0
N2NiLi45YjNiNWJhMzliMWQgMTAwNjQ0Ci0tLSBhL2FyY2gvYWxwaGEvaW5jbHVkZS91YXBpL2Fz
bS9zZXR1cC5oCisrKyBiL2FyY2gvYWxwaGEvaW5jbHVkZS91YXBpL2FzbS9zZXR1cC5oCkBAIC0y
LDYgKzIsNCBAQAogI2lmbmRlZiBfVUFQSV9fQUxQSEFfU0VUVVBfSAogI2RlZmluZSBfVUFQSV9f
QUxQSEFfU0VUVVBfSAogCi0jZGVmaW5lIENPTU1BTkRfTElORV9TSVpFCTI1NgotCiAjZW5kaWYg
LyogX1VBUElfX0FMUEhBX1NFVFVQX0ggKi8KLS0gCjIuMzcuMgo=
