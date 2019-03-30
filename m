From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Sat, 30 Mar 2019 09:42:36 +0000
Subject: Re: [PATCH 2/2] arch: add pidfd and io_uring syscalls everywhere
Message-Id: <20190330094236.GB3801@osiris>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190325143521.34928-1-arnd@arndb.de>
 <20190325144737.703921-1-arnd@arndb.de>
In-Reply-To: <20190325144737.703921-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Will Deacon <will.deacon@arm.com>, linux-mips@vger.kernel.org, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Max Filippov <jcmvbkbc@gmail.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Helge Deller <deller@gmx.de>, Russell King <linux@armlinux.org.uk>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <catalin.marinas@arm.com>, James Hogan <jhogan@kernel.org>, Firoz Khan <firoz.khan@linaro.org>, Matt Turner <mattst88@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-m68k@lists.linux-m68k.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, linux-arm-kernel@lists.infradead.org, Richard Henderson <rth@twiddle.net>, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>, linux-alpha@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S . Miller" <davem@davemloft.net>

On Mon, Mar 25, 2019 at 03:47:37PM +0100, Arnd Bergmann wrote:
> Add the io_uring and pidfd_send_signal system calls to all architectures.
> 
> These system calls are designed to handle both native and compat tasks,
> so all entries are the same across architectures, only arm-compat and
> the generic tale still use an old format.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

> diff --git a/arch/s390/kernel/syscalls/syscall.tbl b/arch/s390/kernel/syscalls/syscall.tbl
> index 02579f95f391..3eb56e639b96 100644
> --- a/arch/s390/kernel/syscalls/syscall.tbl
> +++ b/arch/s390/kernel/syscalls/syscall.tbl
> @@ -426,3 +426,7 @@
>  421	32	rt_sigtimedwait_time64	-				compat_sys_rt_sigtimedwait_time64
>  422	32	futex_time64		-				sys_futex
>  423	32	sched_rr_get_interval_time64	-			sys_sched_rr_get_interval
> +424	common	pidfd_send_signal		sys_pidfd_send_signal
> +425	common	io_uring_setup			sys_io_uring_setup
> +426	common	io_uring_enter			sys_io_uring_enter
> +427	common	io_uring_register		sys_io_uring_register

I was just about to write that io_uring_enter is missing compat
handling, but your first patch actually fixes that. Would have been
good to be cc'ed on both patches :)

For s390:
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
