From: Dinh Nguyen <dinguyen@kernel.org>
Date: Fri, 25 Feb 2022 04:30:31 +0000
Subject: Re: [PATCH v2 12/18] uaccess: fix type mismatch warnings from access_ok()
Message-Id: <824a2d98-e992-0406-518f-adcde2a1372a@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-1-arnd@kernel.org>
 <20220216131332.1489939-13-arnd@kernel.org>
In-Reply-To: <20220216131332.1489939-13-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, arnd@arndb.de, linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux@armlinux.org.uk, will@kernel.org, guoren@kernel.org, bcain@codeaurora.org, geert@linux-m68k.org, monstr@monstr.eu, tsbogend@alpha.franken.de, nickhu@andestech.com, green.hu@gmail.com, shorne@gmail.com, deller@gmx.de, mpe@ellerman.id.au, peterz@infradead.org, mingo@redhat.com, mark.rutland@arm.com, hca@linux.ibm.com, dalias@libc.org, davem@davemloft.net, richard@nod.at, x86@kernel.org, jcmvbkbc@gmail.com, ebiederm@xmission.com, akpm@linux-foundation.org, ardb@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, kernel test robot <lkp@intel.com>



On 2/16/22 07:13, Arnd Bergmann wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> 
> On some architectures, access_ok() does not do any argument type
> checking, so replacing the definition with a generic one causes
> a few warnings for harmless issues that were never caught before.
> 
> Fix the ones that I found either through my own test builds or
> that were reported by the 0-day bot.
> 
> Reported-by: kernel test robot <lkp@intel.com>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>   arch/arc/kernel/process.c           |  2 +-
>   arch/arm/kernel/swp_emulate.c       |  2 +-
>   arch/arm/kernel/traps.c             |  2 +-
>   arch/csky/kernel/signal.c           |  2 +-
>   arch/mips/sibyte/common/sb_tbprof.c |  6 +++---
>   arch/nios2/kernel/signal.c          | 20 +++++++++++---------

Acked-by: Dinh Nguyen <dinguyen@kernel.org>
