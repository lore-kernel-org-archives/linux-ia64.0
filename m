From: Alexandre Ghiti <alexghiti@rivosinc.com>
Date: Thu, 02 Mar 2023 09:35:22 +0000
Subject: [PATCH v4 07/24] mips: Remove COMMAND_LINE_SIZE from uapi
Message-Id: <20230302093539.372962-8-alexghiti@rivosinc.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230302093539.372962-1-alexghiti@rivosinc.com>
In-Reply-To: <20230302093539.372962-1-alexghiti@rivosinc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Jonathan Corbet <corbet@lwn.net>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org
Cc: Palmer Dabbelt <palmer@rivosinc.com>, =?UTF-8?q?Philippe=20Mathieu-Daud=C3=A9?= <philmd@linaro.org>

RnJvbTogUGFsbWVyIERhYmJlbHQgPHBhbG1lckByaXZvc2luYy5jb20+CgpBcyBmYXIgYXMgSSBj
YW4gdGVsbCB0aGlzIGlzIG5vdCB1c2VkIGJ5IHVzZXJzcGFjZSBhbmQgdGh1cyBzaG91bGQgbm90
CmJlIHBhcnQgb2YgdGhlIHVzZXItdmlzaWJsZSBBUEkuCgpTaWduZWQtb2ZmLWJ5OiBQYWxtZXIg
RGFiYmVsdCA8cGFsbWVyQHJpdm9zaW5jLmNvbT4KUmV2aWV3ZWQtYnk6IFBoaWxpcHBlIE1hdGhp
ZXUtRGF1ZMOpIDxwaGlsbWRAbGluYXJvLm9yZz4KLS0tCiBhcmNoL21pcHMvaW5jbHVkZS9hc20v
c2V0dXAuaCAgICAgIHwgMyArKy0KIGFyY2gvbWlwcy9pbmNsdWRlL3VhcGkvYXNtL3NldHVwLmgg
fCAzIC0tLQogMiBmaWxlcyBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyksIDQgZGVsZXRpb25zKC0p
CgpkaWZmIC0tZ2l0IGEvYXJjaC9taXBzL2luY2x1ZGUvYXNtL3NldHVwLmggYi9hcmNoL21pcHMv
aW5jbHVkZS9hc20vc2V0dXAuaAppbmRleCA4YzU2Yjg2MmZkOWMuLmExM2I5MjU5YjQ3NiAxMDA2
NDQKLS0tIGEvYXJjaC9taXBzL2luY2x1ZGUvYXNtL3NldHVwLmgKKysrIGIvYXJjaC9taXBzL2lu
Y2x1ZGUvYXNtL3NldHVwLmgKQEAgLTMsNyArMyw4IEBACiAjZGVmaW5lIF9NSVBTX1NFVFVQX0gK
IAogI2luY2x1ZGUgPGxpbnV4L3R5cGVzLmg+Ci0jaW5jbHVkZSA8dWFwaS9hc20vc2V0dXAuaD4K
KworI2RlZmluZSBDT01NQU5EX0xJTkVfU0laRQk0MDk2CiAKIGV4dGVybiB2b2lkIHByb21fcHV0
Y2hhcihjaGFyKTsKIGV4dGVybiB2b2lkIHNldHVwX2Vhcmx5X3ByaW50ayh2b2lkKTsKZGlmZiAt
LWdpdCBhL2FyY2gvbWlwcy9pbmNsdWRlL3VhcGkvYXNtL3NldHVwLmggYi9hcmNoL21pcHMvaW5j
bHVkZS91YXBpL2FzbS9zZXR1cC5oCmluZGV4IDdkNDhjNDMzYjBjMi4uMTU3YzNjMzkyZmI0IDEw
MDY0NAotLS0gYS9hcmNoL21pcHMvaW5jbHVkZS91YXBpL2FzbS9zZXR1cC5oCisrKyBiL2FyY2gv
bWlwcy9pbmNsdWRlL3VhcGkvYXNtL3NldHVwLmgKQEAgLTIsNyArMiw0IEBACiAjaWZuZGVmIF9V
QVBJX01JUFNfU0VUVVBfSAogI2RlZmluZSBfVUFQSV9NSVBTX1NFVFVQX0gKIAotI2RlZmluZSBD
T01NQU5EX0xJTkVfU0laRQk0MDk2Ci0KLQogI2VuZGlmIC8qIF9VQVBJX01JUFNfU0VUVVBfSCAq
LwotLSAKMi4zNy4yCg==
