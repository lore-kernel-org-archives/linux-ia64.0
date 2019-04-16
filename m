From: Catalin Marinas <catalin.marinas@arm.com>
Date: Tue, 16 Apr 2019 11:41:04 +0000
Subject: Re: [PATCH] [v2] arch: add pidfd and io_uring syscalls everywhere
Message-Id: <20190416114103.GB28994@arrakis.emea.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190415143007.2989285-1-arnd@arndb.de>
In-Reply-To: <20190415143007.2989285-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arch@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Heiko Carstens <heiko.carstens@de.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Yoshinori

On Mon, Apr 15, 2019 at 04:22:57PM +0200, Arnd Bergmann wrote:
> Add the io_uring and pidfd_send_signal system calls to all architectures.
> 
> These system calls are designed to handle both native and compat tasks,
> so all entries are the same across architectures, only arm-compat and
> the generic tale still use an old format.
> 
> Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> (s390)
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> Changes since v1:
> - fix s390 table
> - use 'n64' tag in mips-n64 instead of common.
> ---
>  arch/alpha/kernel/syscalls/syscall.tbl      | 4 ++++
>  arch/arm/tools/syscall.tbl                  | 4 ++++
>  arch/arm64/include/asm/unistd.h             | 2 +-
>  arch/arm64/include/asm/unistd32.h           | 8 ++++++++
>  arch/ia64/kernel/syscalls/syscall.tbl       | 4 ++++
>  arch/m68k/kernel/syscalls/syscall.tbl       | 4 ++++
>  arch/microblaze/kernel/syscalls/syscall.tbl | 4 ++++
>  arch/mips/kernel/syscalls/syscall_n32.tbl   | 4 ++++
>  arch/mips/kernel/syscalls/syscall_n64.tbl   | 4 ++++
>  arch/mips/kernel/syscalls/syscall_o32.tbl   | 4 ++++
>  arch/parisc/kernel/syscalls/syscall.tbl     | 4 ++++
>  arch/powerpc/kernel/syscalls/syscall.tbl    | 4 ++++
>  arch/s390/kernel/syscalls/syscall.tbl       | 4 ++++
>  arch/sh/kernel/syscalls/syscall.tbl         | 4 ++++
>  arch/sparc/kernel/syscalls/syscall.tbl      | 4 ++++
>  arch/xtensa/kernel/syscalls/syscall.tbl     | 4 ++++
>  16 files changed, 65 insertions(+), 1 deletion(-)

For arm64:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
