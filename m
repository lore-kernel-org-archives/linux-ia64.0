From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Mon, 21 Jan 2019 11:59:52 +0000
Subject: Re: [PATCH v2 17/29] syscalls: remove obsolete __IGNORE_ macros
Message-Id: <20190121115952.GD4020@osiris>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190118161835.2259170-1-arnd@arndb.de>
 <20190118161835.2259170-18-arnd@arndb.de>
In-Reply-To: <20190118161835.2259170-18-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: y2038@lists.linaro.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, mattst88@gmail.com, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, geert@linux-m68k.org, monstr@monstr.eu, paul.burton@mips.com, deller@gmx.de, benh@kernel.crashing.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com, dalias@libc.org, davem@davemloft.net, luto@kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, jcmvbkbc@gmail.com, akpm@linux-foundation.org, deepa.kernel@gmail.com, ebiederm@xmission.com, firoz.khan@linaro.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-p

On Fri, Jan 18, 2019 at 05:18:23PM +0100, Arnd Bergmann wrote:
> These are all for ignoring the lack of obsolete system calls,
> which have been marked the same way in scripts/checksyscall.sh,
> so these can be removed.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  arch/mips/include/asm/unistd.h   | 16 ----------------
>  arch/parisc/include/asm/unistd.h |  3 ---
>  arch/s390/include/asm/unistd.h   |  2 --
>  arch/xtensa/include/asm/unistd.h | 12 ------------
>  4 files changed, 33 deletions(-)

For the s390 bits:
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
