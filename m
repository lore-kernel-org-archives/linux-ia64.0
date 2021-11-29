From: Dennis Zhou <dennis@kernel.org>
Date: Mon, 29 Nov 2021 22:55:11 +0000
Subject: Re: [PATCH RFC 0/4] mm: percpu: Cleanup percpu first chunk funciton
Message-Id: <YaVaTwjiZmWz8PKY@fedora>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211121093557.139034-1-wangkefeng.wang@huawei.com>
In-Reply-To: <20211121093557.139034-1-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kefeng Wang <wangkefeng.wang@huawei.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, gregkh@linuxfoundation.org, cl@linux.com, catalin.marinas@arm.com, will@kernel.org, tsbogend@alpha.franken.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org, x86@kernel.org

Hello,

On Sun, Nov 21, 2021 at 05:35:53PM +0800, Kefeng Wang wrote:
> When support page mapping percpu first chunk allocator on arm64, we
> found there are lots of duplicated codes in percpu embed/page first
> chunk allocator. This patchset is aimed to cleanup them and should
> no funciton change, only test on arm64.
> 
> Kefeng Wang (4):
>   mm: percpu: Generalize percpu related config
>   mm: percpu: Add pcpu_fc_cpu_to_node_fn_t typedef
>   mm: percpu: Add generic pcpu_fc_alloc/free funciton
>   mm: percpu: Add generic pcpu_populate_pte() function
> 
>  arch/arm64/Kconfig             |  20 +----
>  arch/ia64/Kconfig              |   9 +--
>  arch/mips/Kconfig              |  10 +--
>  arch/mips/mm/init.c            |  14 +---
>  arch/powerpc/Kconfig           |  17 +---
>  arch/powerpc/kernel/setup_64.c |  92 +--------------------
>  arch/riscv/Kconfig             |  10 +--
>  arch/sparc/Kconfig             |  12 +--
>  arch/sparc/kernel/smp_64.c     | 105 +-----------------------
>  arch/x86/Kconfig               |  17 +---
>  arch/x86/kernel/setup_percpu.c |  66 ++-------------
>  drivers/base/arch_numa.c       |  68 +---------------
>  include/linux/percpu.h         |  13 +--
>  mm/Kconfig                     |  12 +++
>  mm/percpu.c                    | 143 +++++++++++++++++++++++++--------
>  15 files changed, 165 insertions(+), 443 deletions(-)
> 
> -- 
> 2.26.2
> 

I've made a few comments. I think this will be a little bit of a
challenge to get through due to it touching so many architectures. For
ease, it probably makes sense to run it through mny tree, but we'll need
explicit acks as I mentioned.

I like getting rid of the pcpu_alloc_bootmem()/pcpu_free_bootmem()
functions. However, let's keep the implementation identical to x86.


I don't think we should get rid of the populate_pte_fn(). I'm not
comfortable changing x86's implementation. Simply offer a NULL, and if
NULL use the default.

Do you have a tree that intel pulls? I suggest cleaning up the patches
and pushing to a remote branch that they pick up. That would have caught
the mips typo. Send a PR creating a file in [1] for your branch, github
is fine. Basic validation needs to be done before I can pick this up
too on more than arm64.

[1] https://github.com/intel/lkp-tests/tree/master/repo/linux

Thanks,
Dennis
