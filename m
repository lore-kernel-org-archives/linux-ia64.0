From: Kefeng Wang <wangkefeng.wang@huawei.com>
Date: Mon, 29 Nov 2021 02:51:18 +0000
Subject: Re: [PATCH RFC 0/4] mm: percpu: Cleanup percpu first chunk funciton
Message-Id: <4fecd1ac-6c0a-f0fa-1ffb-18f3f266809d@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211121093557.139034-1-wangkefeng.wang@huawei.com>
In-Reply-To: <20211121093557.139034-1-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dennis@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: tj@kernel.org, gregkh@linuxfoundation.org, cl@linux.com, catalin.marinas@arm.com, will@kernel.org, tsbogend@alpha.franken.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org, x86@kernel.org

Hi Dennis and all maintainers, any comments about the changes, many thanks.

On 2021/11/21 17:35, Kefeng Wang wrote:
> When support page mapping percpu first chunk allocator on arm64, we
> found there are lots of duplicated codes in percpu embed/page first
> chunk allocator. This patchset is aimed to cleanup them and should
> no funciton change, only test on arm64.
>
> Kefeng Wang (4):
>    mm: percpu: Generalize percpu related config
>    mm: percpu: Add pcpu_fc_cpu_to_node_fn_t typedef
>    mm: percpu: Add generic pcpu_fc_alloc/free funciton
>    mm: percpu: Add generic pcpu_populate_pte() function
>
>   arch/arm64/Kconfig             |  20 +----
>   arch/ia64/Kconfig              |   9 +--
>   arch/mips/Kconfig              |  10 +--
>   arch/mips/mm/init.c            |  14 +---
>   arch/powerpc/Kconfig           |  17 +---
>   arch/powerpc/kernel/setup_64.c |  92 +--------------------
>   arch/riscv/Kconfig             |  10 +--
>   arch/sparc/Kconfig             |  12 +--
>   arch/sparc/kernel/smp_64.c     | 105 +-----------------------
>   arch/x86/Kconfig               |  17 +---
>   arch/x86/kernel/setup_percpu.c |  66 ++-------------
>   drivers/base/arch_numa.c       |  68 +---------------
>   include/linux/percpu.h         |  13 +--
>   mm/Kconfig                     |  12 +++
>   mm/percpu.c                    | 143 +++++++++++++++++++++++++--------
>   15 files changed, 165 insertions(+), 443 deletions(-)
>
