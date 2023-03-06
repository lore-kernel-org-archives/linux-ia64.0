From: Alexandre Ghiti <alexghiti@rivosinc.com>
Date: Mon, 06 Mar 2023 10:04:57 +0000
Subject: [PATCH v5 15/26] arc: Remove empty <uapi/asm/setup.h>
Message-Id: <20230306100508.1171812-16-alexghiti@rivosinc.com>
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
cGUgTWF0aGlldS1EYXVkw6kgPHBoaWxtZEBsaW5hcm8ub3JnPgotLS0KIGFyY2gvYXJjL2luY2x1
ZGUvYXNtL3NldHVwLmggICAgICB8IDEgLQogYXJjaC9hcmMvaW5jbHVkZS91YXBpL2FzbS9zZXR1
cC5oIHwgNiAtLS0tLS0KIDIgZmlsZXMgY2hhbmdlZCwgNyBkZWxldGlvbnMoLSkKIGRlbGV0ZSBt
b2RlIDEwMDY0NCBhcmNoL2FyYy9pbmNsdWRlL3VhcGkvYXNtL3NldHVwLmgKCmRpZmYgLS1naXQg
YS9hcmNoL2FyYy9pbmNsdWRlL2FzbS9zZXR1cC5oIGIvYXJjaC9hcmMvaW5jbHVkZS9hc20vc2V0
dXAuaAppbmRleCAwMjhhOGNmNzYyMDYuLmZlNDVmZjQ2ODFiYyAxMDA2NDQKLS0tIGEvYXJjaC9h
cmMvaW5jbHVkZS9hc20vc2V0dXAuaAorKysgYi9hcmNoL2FyYy9pbmNsdWRlL2FzbS9zZXR1cC5o
CkBAIC03LDcgKzcsNiBAQAogCiAKICNpbmNsdWRlIDxsaW51eC90eXBlcy5oPgotI2luY2x1ZGUg
PHVhcGkvYXNtL3NldHVwLmg+CiAKICNkZWZpbmUgQ09NTUFORF9MSU5FX1NJWkUgMjU2CiAKZGlm
ZiAtLWdpdCBhL2FyY2gvYXJjL2luY2x1ZGUvdWFwaS9hc20vc2V0dXAuaCBiL2FyY2gvYXJjL2lu
Y2x1ZGUvdWFwaS9hc20vc2V0dXAuaApkZWxldGVkIGZpbGUgbW9kZSAxMDA2NDQKaW5kZXggYTZk
NGU0NDkzOGJlLi4wMDAwMDAwMDAwMDAKLS0tIGEvYXJjaC9hcmMvaW5jbHVkZS91YXBpL2FzbS9z
ZXR1cC5oCisrKyAvZGV2L251bGwKQEAgLTEsNiArMCwwIEBACi0vKgotICogc2V0dXAuaCBpcyBw
YXJ0IG9mIHVzZXJzcGFjZSBoZWFkZXIgQUJJIHNvIFVBUEkgc2NyaXB0cyBoYXZlIHRvIGdlbmVy
YXRlIGl0Ci0gKiBldmVuIGlmIHRoZXJlJ3Mgbm90aGluZyB0byBleHBvcnQgLSBjYXVzaW5nIGVt
cHR5IDx1YXBpL2FzbS9zZXR1cC5oPgotICogSG93ZXZlciB0byBwcmV2ZW50ICJwYXRjaCIgZnJv
bSBkaXNjYXJkaW5nIGl0IHdlIGFkZCB0aGlzIHBsYWNlaG9sZGVyCi0gKiBjb21tZW50Ci0gKi8K
LS0gCjIuMzcuMgo=
