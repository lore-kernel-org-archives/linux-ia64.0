From: Alexandre Ghiti <alexghiti@rivosinc.com>
Date: Thu, 02 Mar 2023 09:35:39 +0000
Subject: [PATCH v4 24/24] s390: Remove empty <uapi/asm/setup.h>
Message-Id: <20230302093539.372962-25-alexghiti@rivosinc.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230302093539.372962-1-alexghiti@rivosinc.com>
In-Reply-To: <20230302093539.372962-1-alexghiti@rivosinc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Jonathan Corbet <corbet@lwn.net>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org
Cc: Palmer Dabbelt <palmer@rivosinc.com>, =?UTF-8?q?Philippe=20Mathieu-Daud=C3=A9?= <philmd@linaro.org>

RnJvbTogUGFsbWVyIERhYmJlbHQgPHBhbG1lckByaXZvc2luYy5jb20+CgpTaWduZWQtb2ZmLWJ5
OiBQYWxtZXIgRGFiYmVsdCA8cGFsbWVyQHJpdm9zaW5jLmNvbT4KQWNrZWQtYnk6IEhlaWtvIENh
cnN0ZW5zIDxoY2FAbGludXguaWJtLmNvbT4KUmV2aWV3ZWQtYnk6IFBoaWxpcHBlIE1hdGhpZXUt
RGF1ZMOpIDxwaGlsbWRAbGluYXJvLm9yZz4KLS0tCiBhcmNoL3MzOTAvaW5jbHVkZS9hc20vc2V0
dXAuaCAgICAgIHwgMSAtCiBhcmNoL3MzOTAvaW5jbHVkZS91YXBpL2FzbS9zZXR1cC5oIHwgMSAt
CiAyIGZpbGVzIGNoYW5nZWQsIDIgZGVsZXRpb25zKC0pCiBkZWxldGUgbW9kZSAxMDA2NDQgYXJj
aC9zMzkwL2luY2x1ZGUvdWFwaS9hc20vc2V0dXAuaAoKZGlmZiAtLWdpdCBhL2FyY2gvczM5MC9p
bmNsdWRlL2FzbS9zZXR1cC5oIGIvYXJjaC9zMzkwL2luY2x1ZGUvYXNtL3NldHVwLmgKaW5kZXgg
MTc3YmY2ZGVhYTI3Li45OWMxY2M5NzM1MGEgMTAwNjQ0Ci0tLSBhL2FyY2gvczM5MC9pbmNsdWRl
L2FzbS9zZXR1cC5oCisrKyBiL2FyY2gvczM5MC9pbmNsdWRlL2FzbS9zZXR1cC5oCkBAIC03LDcg
KzcsNiBAQAogI2RlZmluZSBfQVNNX1MzOTBfU0VUVVBfSAogCiAjaW5jbHVkZSA8bGludXgvYml0
cy5oPgotI2luY2x1ZGUgPHVhcGkvYXNtL3NldHVwLmg+CiAjaW5jbHVkZSA8bGludXgvYnVpbGRf
YnVnLmg+CiAKICNkZWZpbmUgUEFSTUFSRUEJCTB4MTA0MDAKZGlmZiAtLWdpdCBhL2FyY2gvczM5
MC9pbmNsdWRlL3VhcGkvYXNtL3NldHVwLmggYi9hcmNoL3MzOTAvaW5jbHVkZS91YXBpL2FzbS9z
ZXR1cC5oCmRlbGV0ZWQgZmlsZSBtb2RlIDEwMDY0NAppbmRleCA1OThkNzY5ZTc2ZGYuLjAwMDAw
MDAwMDAwMAotLS0gYS9hcmNoL3MzOTAvaW5jbHVkZS91YXBpL2FzbS9zZXR1cC5oCisrKyAvZGV2
L251bGwKQEAgLTEgKzAsMCBAQAotLyogU1BEWC1MaWNlbnNlLUlkZW50aWZpZXI6IEdQTC0yLjAg
V0lUSCBMaW51eC1zeXNjYWxsLW5vdGUgKi8KLS0gCjIuMzcuMgo=
