From: Anatoly Pugachev <matorola@gmail.com>
Date: Wed, 17 Mar 2021 14:03:22 +0000
Subject: Re: [PATCH v2] mm: Move mem_init_print_info() into mm_init()
Message-Id: <CADxRZqwFokuZrhA6GFr=whM3s7BqZpzo8yq=TW6YEr=eeEUH0A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4d488195-7281-9238-b30d-9f89a6100fb9@csgroup.eu> <20210317015210.33641-1-wangkefeng.wang@huawei.com>
In-Reply-To: <20210317015210.33641-1-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kefeng Wang <wangkefeng.wang@huawei.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Richard Henderson <rth@twiddle.net>, Guo Ren <guoren@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Huacai Chen <chenhuacai@kernel.org>, Jonas Bonn <jonas@southpole.se>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, "David S. Miller" <davem@davemloft.net>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, Sparc kernel list <sparclinux@vger.kernel.org>, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org

On Wed, Mar 17, 2021 at 4:51 AM Kefeng Wang <wangkefeng.wang@huawei.com> wrote:
>
> mem_init_print_info() is called in mem_init() on each architecture,
> and pass NULL argument, so using void argument and move it into mm_init().
>
> Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
> ---
> v2:
> - Cleanup 'str' line suggested by Christophe and ACK

applied patch (5.12.0-rc3-00020-g1df27313f50a-dirty) over linus.git
and tested boot on a sparc64 virtual machine (ldom) - boots.
