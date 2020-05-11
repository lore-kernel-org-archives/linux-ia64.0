From: Christoph Hellwig <hch@lst.de>
Date: Mon, 11 May 2020 15:15:35 +0000
Subject: Re: [PATCH 02/31] arm64: fix the flush_icache_range arguments in machine_kexec
Message-Id: <20200511151535.GC28634@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200510075510.987823-1-hch@lst.de> <20200510075510.987823-3-hch@lst.de> <20200511075115.GA16134@willie-the-truck> <20200511110014.GA19176@gaia>
In-Reply-To: <20200511110014.GA19176@gaia>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will@kernel.org>, Christoph Hellwig <hch@lst.de>, james.morse@arm.com, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Roman Zippel <zippel@linux-m68k.org>, Jessica Yu <jeyu@kernel.org>, Michal Simek <monstr@monstr.eu>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.orglinux

On Mon, May 11, 2020 at 12:00:14PM +0100, Catalin Marinas wrote:
> Anyway, I think Christoph's patch needs to go in with a fixes tag:
> 
> Fixes: d28f6df1305a ("arm64/kexec: Add core kexec support")
> Cc: <stable@vger.kernel.org> # 4.8.x-
> 
> and we'll change these functions/helpers going forward for arm64.
> 
> Happy to pick this up via the arm64 for-next/fixes branch.

Please do, there are no dependencies on it in this series (I originally
planned to switch flush_icache_range to pass a kernel pointer + len
instead of the strange unsigned long start and end.  That still looks
very useful, but the series already is way too large, so I'm going to
defer that change for another merge window).
