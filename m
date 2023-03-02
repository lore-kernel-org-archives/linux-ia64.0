From: Alexandre Ghiti <alexghiti@rivosinc.com>
Date: Thu, 02 Mar 2023 09:35:16 +0000
Subject: [PATCH v4 01/24] alpha: Remove COMMAND_LINE_SIZE from uapi
Message-Id: <20230302093539.372962-2-alexghiti@rivosinc.com>
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
ZXUtRGF1ZMOpIDxwaGlsbWRAbGluYXJvLm9yZz4KLS0tCiBhcmNoL2FscGhhL2luY2x1ZGUvYXNt
L3NldHVwLmggICAgICB8IDQgKystLQogYXJjaC9hbHBoYS9pbmNsdWRlL3VhcGkvYXNtL3NldHVw
LmggfCAyIC0tCiAyIGZpbGVzIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgNCBkZWxldGlvbnMo
LSkKCmRpZmYgLS1naXQgYS9hcmNoL2FscGhhL2luY2x1ZGUvYXNtL3NldHVwLmggYi9hcmNoL2Fs
cGhhL2luY2x1ZGUvYXNtL3NldHVwLmgKaW5kZXggMjYyYWFiOTllMzkxLi5lYTA4Y2E0NWVmYTgg
MTAwNjQ0Ci0tLSBhL2FyY2gvYWxwaGEvaW5jbHVkZS9hc20vc2V0dXAuaAorKysgYi9hcmNoL2Fs
cGhhL2luY2x1ZGUvYXNtL3NldHVwLmgKQEAgLTIsOCArMiw2IEBACiAjaWZuZGVmIF9fQUxQSEFf
U0VUVVBfSAogI2RlZmluZSBfX0FMUEhBX1NFVFVQX0gKIAotI2luY2x1ZGUgPHVhcGkvYXNtL3Nl
dHVwLmg+Ci0KIC8qCiAgKiBXZSBsZWF2ZSBvbmUgcGFnZSBmb3IgdGhlIGluaXRpYWwgc3RhY2sg
cGFnZSwgYW5kIG9uZSBwYWdlIGZvcgogICogdGhlIGluaXRpYWwgcHJvY2VzcyBzdHJ1Y3R1cmUu
IEFsc28sIHRoZSBjb25zb2xlIGVhdHMgMyBNQiBmb3IKQEAgLTE0LDYgKzEyLDggQEAKIC8qIFJl
bW92ZSB3aGVuIG9mZmljaWFsIE1JTE8gc291cmNlcyBoYXZlIEVMRiBzdXBwb3J0OiAqLwogI2Rl
ZmluZSBCT09UX1NJWkUJKDE2KjEwMjQpCiAKKyNkZWZpbmUgQ09NTUFORF9MSU5FX1NJWkUJMjU2
CisKICNpZmRlZiBDT05GSUdfQUxQSEFfTEVHQUNZX1NUQVJUX0FERFJFU1MKICNkZWZpbmUgS0VS
TkVMX1NUQVJUX1BIWVMJMHgzMDAwMDAgLyogT2xkIGJvb3Rsb2FkZXJzIGhhcmRjb2RlZCB0aGlz
LiAgKi8KICNlbHNlCmRpZmYgLS1naXQgYS9hcmNoL2FscGhhL2luY2x1ZGUvdWFwaS9hc20vc2V0
dXAuaCBiL2FyY2gvYWxwaGEvaW5jbHVkZS91YXBpL2FzbS9zZXR1cC5oCmluZGV4IGY4ODFlYTU5
NDdjYi4uOWIzYjViYTM5YjFkIDEwMDY0NAotLS0gYS9hcmNoL2FscGhhL2luY2x1ZGUvdWFwaS9h
c20vc2V0dXAuaAorKysgYi9hcmNoL2FscGhhL2luY2x1ZGUvdWFwaS9hc20vc2V0dXAuaApAQCAt
Miw2ICsyLDQgQEAKICNpZm5kZWYgX1VBUElfX0FMUEhBX1NFVFVQX0gKICNkZWZpbmUgX1VBUElf
X0FMUEhBX1NFVFVQX0gKIAotI2RlZmluZSBDT01NQU5EX0xJTkVfU0laRQkyNTYKLQogI2VuZGlm
IC8qIF9VQVBJX19BTFBIQV9TRVRVUF9IICovCi0tIAoyLjM3LjIK
