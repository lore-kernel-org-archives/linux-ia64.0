From: "Arnd Bergmann" <arnd@arndb.de>
Date: Thu, 29 Dec 2022 09:32:19 +0000
Subject: Re: [PATCH 02/19] arch/arc: rename internal name __xchg to __arch_xchg
Message-Id: <78b23407-bdd0-4b1b-bf6e-ecd4c00294ab@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221222114635.1251934-1-andrzej.hajda@intel.com>
 <20221222114635.1251934-3-andrzej.hajda@intel.com>
In-Reply-To: <20221222114635.1251934-3-andrzej.hajda@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrzej Hajda <andrzej.hajda@intel.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org
Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Boqun Feng <boqun.feng@gmail.com>, Mark Rutland <mark.rutland@arm.com>

On Thu, Dec 22, 2022, at 12:46, Andrzej Hajda wrote:
> __xchg will be used for non-atomic xchg macro.
>
> Signed-off-by: Andrzej Hajda <andrzej.hajda@intel.com>
> ---
>  arch/arc/include/asm/cmpxchg.h | 4 ++--

Reviewed-by: Arnd Bergmann <arnd@arndb.de>

for all the arch/*/include/asm/cmpxchg.h changes.

Since these patches are all the same, and they have identical
subject and description texts, I would suggest combining them
into a single patch to keep the series more compact.

Having them separate would allow merging the patches through
the individual architecture maintainer trees, but that in turn
would mean waiting longer to get it all merged, but in this
case it seems way easier to go through the asm-generic
tree.

     Arnd
