From: Alexandre Ghiti <alexghiti@rivosinc.com>
Date: Thu, 02 Mar 2023 09:35:23 +0000
Subject: [PATCH v4 08/24] parisc: Remove COMMAND_LINE_SIZE from uapi
Message-Id: <20230302093539.372962-9-alexghiti@rivosinc.com>
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
ZXUtRGF1ZMOpIDxwaGlsbWRAbGluYXJvLm9yZz4KQWNrZWQtYnk6IEhlbGdlIERlbGxlciA8ZGVs
bGVyQGdteC5kZT4KLS0tCiBhcmNoL3BhcmlzYy9pbmNsdWRlL2FzbS9zZXR1cC5oICAgICAgfCA3
ICsrKysrKysKIGFyY2gvcGFyaXNjL2luY2x1ZGUvdWFwaS9hc20vc2V0dXAuaCB8IDIgLS0KIDIg
ZmlsZXMgY2hhbmdlZCwgNyBpbnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQogY3JlYXRlIG1v
ZGUgMTAwNjQ0IGFyY2gvcGFyaXNjL2luY2x1ZGUvYXNtL3NldHVwLmgKCmRpZmYgLS1naXQgYS9h
cmNoL3BhcmlzYy9pbmNsdWRlL2FzbS9zZXR1cC5oIGIvYXJjaC9wYXJpc2MvaW5jbHVkZS9hc20v
c2V0dXAuaApuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAwMDAwMDAwMDAwMDAuLjc4YjJmNGVj
N2Q2NQotLS0gL2Rldi9udWxsCisrKyBiL2FyY2gvcGFyaXNjL2luY2x1ZGUvYXNtL3NldHVwLmgK
QEAgLTAsMCArMSw3IEBACisvKiBTUERYLUxpY2Vuc2UtSWRlbnRpZmllcjogR1BMLTIuMCBXSVRI
IExpbnV4LXN5c2NhbGwtbm90ZSAqLworI2lmbmRlZiBfUEFSSVNDX1NFVFVQX0gKKyNkZWZpbmUg
X1BBUklTQ19TRVRVUF9ICisKKyNkZWZpbmUgQ09NTUFORF9MSU5FX1NJWkUJMTAyNAorCisjZW5k
aWYgLyogX1BBUklTQ19TRVRVUF9IICovCmRpZmYgLS1naXQgYS9hcmNoL3BhcmlzYy9pbmNsdWRl
L3VhcGkvYXNtL3NldHVwLmggYi9hcmNoL3BhcmlzYy9pbmNsdWRlL3VhcGkvYXNtL3NldHVwLmgK
aW5kZXggNzhiMmY0ZWM3ZDY1Li5iZmFkODk0MjhlNDcgMTAwNjQ0Ci0tLSBhL2FyY2gvcGFyaXNj
L2luY2x1ZGUvdWFwaS9hc20vc2V0dXAuaAorKysgYi9hcmNoL3BhcmlzYy9pbmNsdWRlL3VhcGkv
YXNtL3NldHVwLmgKQEAgLTIsNiArMiw0IEBACiAjaWZuZGVmIF9QQVJJU0NfU0VUVVBfSAogI2Rl
ZmluZSBfUEFSSVNDX1NFVFVQX0gKIAotI2RlZmluZSBDT01NQU5EX0xJTkVfU0laRQkxMDI0Ci0K
ICNlbmRpZiAvKiBfUEFSSVNDX1NFVFVQX0ggKi8KLS0gCjIuMzcuMgo=
