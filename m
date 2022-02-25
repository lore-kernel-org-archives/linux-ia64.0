From: Dinh Nguyen <dinguyen@kernel.org>
Date: Fri, 25 Feb 2022 04:33:46 +0000
Subject: Re: [PATCH v2 18/18] uaccess: drop maining CONFIG_SET_FS users
Message-Id: <3927b6f5-c8d0-1421-407d-850ede02dd0f@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-1-arnd@kernel.org>
 <20220216131332.1489939-19-arnd@kernel.org>
In-Reply-To: <20220216131332.1489939-19-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, arnd@arndb.de, linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux@armlinux.org.uk, will@kernel.org, guoren@kernel.org, bcain@codeaurora.org, geert@linux-m68k.org, monstr@monstr.eu, tsbogend@alpha.franken.de, nickhu@andestech.com, green.hu@gmail.com, shorne@gmail.com, deller@gmx.de, mpe@ellerman.id.au, peterz@infradead.org, mingo@redhat.com, mark.rutland@arm.com, hca@linux.ibm.com, dalias@libc.org, davem@davemloft.net, richard@nod.at, x86@kernel.org, jcmvbkbc@gmail.com, ebiederm@xmission.com, akpm@linux-foundation.org, ardb@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org



On 2/16/22 07:13, Arnd Bergmann wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> 
> There are no remaining callers of set_fs(), so CONFIG_SET_FS
> can be removed globally, along with the thread_info field and
> any references to it.
> 
> This turns access_ok() into a cheaper check against TASK_SIZE_MAX.
> 
> With CONFIG_SET_FS gone, so drop all remaining references to
> set_fs()/get_fs(), mm_segment_t and uaccess_kernel().
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>   arch/Kconfig                              |  3 -
>   arch/alpha/Kconfig                        |  1 -
>   arch/alpha/include/asm/processor.h        |  4 --
>   arch/alpha/include/asm/thread_info.h      |  2 -
>   arch/alpha/include/asm/uaccess.h          | 19 ------
>   arch/arc/Kconfig                          |  1 -
>   arch/arc/include/asm/segment.h            | 20 -------
>   arch/arc/include/asm/thread_info.h        |  3 -
>   arch/arc/include/asm/uaccess.h            |  1 -
>   arch/arm/lib/uaccess_with_memcpy.c        | 10 ----
>   arch/csky/Kconfig                         |  1 -
>   arch/csky/include/asm/processor.h         |  2 -
>   arch/csky/include/asm/segment.h           | 10 ----
>   arch/csky/include/asm/thread_info.h       |  2 -
>   arch/csky/include/asm/uaccess.h           |  3 -
>   arch/csky/kernel/asm-offsets.c            |  1 -
>   arch/h8300/Kconfig                        |  1 -
>   arch/h8300/include/asm/processor.h        |  1 -
>   arch/h8300/include/asm/segment.h          | 40 -------------
>   arch/h8300/include/asm/thread_info.h      |  3 -
>   arch/h8300/kernel/entry.S                 |  1 -
>   arch/h8300/kernel/head_ram.S              |  1 -
>   arch/h8300/mm/init.c                      |  6 --
>   arch/h8300/mm/memory.c                    |  1 -
>   arch/hexagon/Kconfig                      |  1 -
>   arch/hexagon/include/asm/thread_info.h    |  6 --
>   arch/hexagon/kernel/process.c             |  1 -
>   arch/microblaze/Kconfig                   |  1 -
>   arch/microblaze/include/asm/thread_info.h |  6 --
>   arch/microblaze/include/asm/uaccess.h     | 24 --------
>   arch/microblaze/kernel/asm-offsets.c      |  1 -
>   arch/microblaze/kernel/process.c          |  1 -
>   arch/nds32/Kconfig                        |  1 -
>   arch/nds32/include/asm/thread_info.h      |  4 --
>   arch/nds32/include/asm/uaccess.h          | 15 +----
>   arch/nds32/kernel/process.c               |  5 +-
>   arch/nds32/mm/alignment.c                 |  3 -
>   arch/nios2/Kconfig                        |  1 -
>   arch/nios2/include/asm/thread_info.h      |  9 ---
>   arch/nios2/include/asm/uaccess.h          | 12 ----

For NIOS2:

Acked-by: Dinh Nguyen <dinguyen@kernel.org>
