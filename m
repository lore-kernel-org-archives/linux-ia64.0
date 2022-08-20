From: Brian Cain <bcain@quicinc.com>
Date: Sat, 20 Aug 2022 17:42:15 +0000
Subject: RE: [PATCH] kernel: exit: cleanup release_thread()
Message-Id: <BN7PR02MB4194B2148C8F9183AD6504B3B86F9@BN7PR02MB4194.namprd02.prod.outlook.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220819014406.32266-1-wangkefeng.wang@huawei.com>
In-Reply-To: <20220819014406.32266-1-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kefeng Wang <wangkefeng.wang@huawei.com>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Dinh Nguyen <dinguyen@kernel.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "x86@kernel.org" <x86@kernel.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "loongarch@lists.linux.dev" <loongarch@lists.linux.dev>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>



> -----Original Message-----
> From: Kefeng Wang <wangkefeng.wang@huawei.com>
...
> Only x86 has own release_thread(), introduce a new weak
> release_thread() function to clean empty definitions in
> other ARCHs.
> 
> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
> ---

Acked-by: Brian Cain <bcain@quicinc.com>
