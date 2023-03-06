From: Alexandre Ghiti <alexghiti@rivosinc.com>
Date: Mon, 06 Mar 2023 10:05:03 +0000
Subject: [PATCH v5 21/26] x86: Remove empty <uapi/asm/setup.h>
Message-Id: <20230306100508.1171812-22-alexghiti@rivosinc.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230306100508.1171812-1-alexghiti@rivosinc.com>
In-Reply-To: <20230306100508.1171812-1-alexghiti@rivosinc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Greg KH <gregkh@linuxfoundation.org>, Jonathan Corbet <corbet@lwn.net>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org
Cc: Palmer Dabbelt <palmer@rivosinc.com>, Alexandre Ghiti <alexghiti@rivosinc.com>, =?UTF-8?q?Philippe=20Mathieu-Daud=C3=A9?= <philmd@linaro.org>

RnJvbTogUGFsbWVyIERhYmJlbHQgPHBhbG1lckByaXZvc2luYy5jb20+CgpTaWduZWQtb2ZmLWJ5
OiBQYWxtZXIgRGFiYmVsdCA8cGFsbWVyQHJpdm9zaW5jLmNvbT4KU2lnbmVkLW9mZi1ieTogQWxl
eGFuZHJlIEdoaXRpIDxhbGV4Z2hpdGlAcml2b3NpbmMuY29tPgpSZXZpZXdlZC1ieTogUGhpbGlw
cGUgTWF0aGlldS1EYXVkw6kgPHBoaWxtZEBsaW5hcm8ub3JnPgotLS0KIGFyY2gveDg2L2luY2x1
ZGUvYXNtL3NldHVwLmggICAgICB8IDIgLS0KIGFyY2gveDg2L2luY2x1ZGUvdWFwaS9hc20vc2V0
dXAuaCB8IDEgLQogMiBmaWxlcyBjaGFuZ2VkLCAzIGRlbGV0aW9ucygtKQogZGVsZXRlIG1vZGUg
MTAwNjQ0IGFyY2gveDg2L2luY2x1ZGUvdWFwaS9hc20vc2V0dXAuaAoKZGlmZiAtLWdpdCBhL2Fy
Y2gveDg2L2luY2x1ZGUvYXNtL3NldHVwLmggYi9hcmNoL3g4Ni9pbmNsdWRlL2FzbS9zZXR1cC5o
CmluZGV4IGYzN2NiZmY3MzU0Yy4uNDQ5YjUwYTJmMzkwIDEwMDY0NAotLS0gYS9hcmNoL3g4Ni9p
bmNsdWRlL2FzbS9zZXR1cC5oCisrKyBiL2FyY2gveDg2L2luY2x1ZGUvYXNtL3NldHVwLmgKQEAg
LTIsOCArMiw2IEBACiAjaWZuZGVmIF9BU01fWDg2X1NFVFVQX0gKICNkZWZpbmUgX0FTTV9YODZf
U0VUVVBfSAogCi0jaW5jbHVkZSA8dWFwaS9hc20vc2V0dXAuaD4KLQogI2RlZmluZSBDT01NQU5E
X0xJTkVfU0laRSAyMDQ4CiAKICNpbmNsdWRlIDxsaW51eC9saW5rYWdlLmg+CmRpZmYgLS1naXQg
YS9hcmNoL3g4Ni9pbmNsdWRlL3VhcGkvYXNtL3NldHVwLmggYi9hcmNoL3g4Ni9pbmNsdWRlL3Vh
cGkvYXNtL3NldHVwLmgKZGVsZXRlZCBmaWxlIG1vZGUgMTAwNjQ0CmluZGV4IDc5YTk2MjZiNTUw
MC4uMDAwMDAwMDAwMDAwCi0tLSBhL2FyY2gveDg2L2luY2x1ZGUvdWFwaS9hc20vc2V0dXAuaAor
KysgL2Rldi9udWxsCkBAIC0xICswLDAgQEAKLS8qICovCi0tIAoyLjM3LjIK
