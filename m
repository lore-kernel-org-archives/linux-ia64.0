From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 09 Jun 2021 11:30:39 +0000
Subject: Re: [PATCH v2 0/9] Remove DISCINTIGMEM memory model
Message-Id: <CAK8P3a2tZDJDqgr9-1vJrnbDhd_36eKq8LMEznDkU7rvuAnAag@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210604064916.26580-1-rppt@kernel.org>
In-Reply-To: <20210604064916.26580-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Jonathan Corbet <corbet@lwn.net>, Matt Turner <mattst88@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Richard Henderson <rth@twiddle.net>, Vineet Gupta <vgupta@synopsys.com>, kexec@lists.infradead.org, alpha <linux-alpha@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-riscv <linux-riscv@lists.infradead.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>

On Fri, Jun 4, 2021 at 8:49 AM Mike Rapoport <rppt@kernel.org> wrote:
>
> From: Mike Rapoport <rppt@linux.ibm.com>
>
> Hi,
>
> SPARSEMEM memory model was supposed to entirely replace DISCONTIGMEM a
> (long) while ago. The last architectures that used DISCONTIGMEM were
> updated to use other memory models in v5.11 and it is about the time to
> entirely remove DISCONTIGMEM from the kernel.
>
> This set removes DISCONTIGMEM from alpha, arc and m68k, simplifies memory
> model selection in mm/Kconfig and replaces usage of redundant
> CONFIG_NEED_MULTIPLE_NODES and CONFIG_FLAT_NODE_MEM_MAP with CONFIG_NUMA
> and CONFIG_FLATMEM respectively.
>
> I've also removed NUMA support on alpha that was BROKEN for more than 15
> years.
>
> There were also minor updates all over arch/ to remove mentions of
> DISCONTIGMEM in comments and #ifdefs.

Hi Mike and Andrew,

It looks like everyone is happy with this version so far. How should we merge it
for linux-next? I'm happy to take it through the asm-generic tree, but linux-mm
would fit at least as well. In case we go for linux-mm, feel free to add

Acked-by: Arnd Bergmann <arnd@arndb.de>

for the whole series.
