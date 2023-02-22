From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 22 Feb 2023 17:04:31 +0000
Subject: Re: [PATCH v5 0/7] Introduce __xchg, non-atomic xchg
Message-Id: <Y/ZLH5F8LA3H10aL@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230118153529.57695-1-andrzej.hajda@intel.com>
In-Reply-To: <20230118153529.57695-1-andrzej.hajda@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrzej Hajda <andrzej.hajda@intel.com>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, Arnd Bergmann <arnd@arndb.de>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Boqun Feng <boqun.feng@gmail.com>, Mark Rutland <mark.rutland@arm.com>

On Wed, Jan 18, 2023 at 04:35:22PM +0100, Andrzej Hajda wrote:

> Andrzej Hajda (7):
>   arch: rename all internal names __xchg to __arch_xchg
>   linux/include: add non-atomic version of xchg
>   arch/*/uprobes: simplify arch_uretprobe_hijack_return_addr
>   llist: simplify __llist_del_all
>   io_uring: use __xchg if possible
>   qed: use __xchg if possible
>   drm/i915/gt: use __xchg instead of internal helper

Nothing crazy in here I suppose, I somewhat wonder why you went through
the trouble, but meh.

You want me to take this through te locking tree (for the next cycle,
not this one) where I normally take atomic things or does someone else
want this?
