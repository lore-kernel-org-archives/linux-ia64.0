From: Huacai Chen <chenhuacai@kernel.org>
Date: Sun, 21 Aug 2022 14:57:53 +0000
Subject: Re: [PATCH] kernel: exit: cleanup release_thread()
Message-Id: <CAAhV-H4qffsU0Tmb7_b0iQh7x3Bks2vVrmmvL+0Z0CVaVggsYg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220819014406.32266-1-wangkefeng.wang@huawei.com> <YwIc7qbCWpIVKR2j@arm.com>
In-Reply-To: <YwIc7qbCWpIVKR2j@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Kefeng Wang <wangkefeng.wang@huawei.com>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Brian Cain <bcain@quicinc.com>, WANG Xuerui <kernel@xen0n.name>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Dinh Nguyen <dinguyen@kernel.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-alpha@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-snps-arc@lists.infradead.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:MIPS" <linux-mips@vger.kernel.org>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv <linux-riscv@lists.infradead.org>, linux-s390@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, linux-um <linux-um@lists.infradead.org>, linux-xtensa@linux-xtensa.org, Andrew Morton <akpm@linux-foundation.org>

For LoongArch parts:

Acked-by: Huacai Chen <chenhuacai@kernel.org>

On Sun, Aug 21, 2022 at 7:54 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Fri, Aug 19, 2022 at 09:44:06AM +0800, Kefeng Wang wrote:
> > Only x86 has own release_thread(), introduce a new weak
> > release_thread() function to clean empty definitions in
> > other ARCHs.
> >
> > Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
> [...]
> >  arch/arm64/include/asm/processor.h      | 3 ---
> >  arch/arm64/kernel/process.c             | 4 ----
>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
