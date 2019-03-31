From: Michael Ellerman <mpe@ellerman.id.au>
Date: Sun, 31 Mar 2019 09:47:13 +0000
Subject: Re: [PATCH 2/2] arch: add pidfd and io_uring syscalls everywhere
Message-Id: <87y34vl6ji.fsf@concordia.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190325143521.34928-1-arnd@arndb.de>
 <20190325144737.703921-1-arnd@arndb.de>
In-Reply-To: <20190325144737.703921-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mips@vger.kernel.org, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Max Filippov <jcmvbkbc@gmail.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Helge Deller <deller@gmx.de>, Russell King <linux@armlinux.org.uk>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <catalin.marinas@arm.com>, James Hogan <jhogan@kernel.org>, Firoz Khan <firoz.khan@linaro.org>, Matt Turner <mattst88@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, Will Deacon <will.deacon@arm.com>, linux-m68k@lists.linux-m68k.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, linux-arm-kernel@lists.infradead.org, Richard Henderson <rth@twiddle.net>, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>, linux-alpha@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, "David S . Miller" <davem@davemloft.net>

Arnd Bergmann <arnd@arndb.de> writes:
> Add the io_uring and pidfd_send_signal system calls to all architectures.
>
> These system calls are designed to handle both native and compat tasks,
> so all entries are the same across architectures, only arm-compat and
> the generic tale still use an old format.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
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

Have you done any testing?

I'd rather not wire up syscalls that have never been tested at all on
powerpc.

cheers
