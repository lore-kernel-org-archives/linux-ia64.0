From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 03 Apr 2019 02:47:50 +0000
Subject: Re: [PATCH 2/2] arch: add pidfd and io_uring syscalls everywhere
Message-Id: <87tvff24a1.fsf@concordia.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190325143521.34928-1-arnd@arndb.de>
 <20190325144737.703921-1-arnd@arndb.de>
In-Reply-To: <20190325144737.703921-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mips@vger.kernel.org, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Max Filippov <jcmvbkbc@gmail.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Helge Deller <deller@gmx.de>, Russell King <linux@armlinux.org.uk>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <catalin.marinas@arm.com>, James Hogan <jhogan@kernel.org>, Firoz Khan <firoz.khan@linaro.org>, Matt Turner <mattst88@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, Will Deacon <will.deacon@arm.com>, linux-m68k@lists.linux-m68k.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, linux-arm-kernel@lists.infradead.org, Richard Henderson <rth@twiddle.net>, Jens Axboe <axboe@kernel.dk>, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>, linux-alpha@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, "David S . Miller" <davem@davemloft.net>

Arnd Bergmann <arnd@arndb.de> writes:
> diff --git a/arch/powerpc/kernel/syscalls/syscall.tbl b/arch/powerpc/kern=
el/syscalls/syscall.tbl
> index b18abb0c3dae..00f5a63c8d9a 100644
> --- a/arch/powerpc/kernel/syscalls/syscall.tbl
> +++ b/arch/powerpc/kernel/syscalls/syscall.tbl
> @@ -505,3 +505,7 @@
>  421	32	rt_sigtimedwait_time64		sys_rt_sigtimedwait		compat_sys_rt_sigtim=
edwait_time64
>  422	32	futex_time64			sys_futex			sys_futex
>  423	32	sched_rr_get_interval_time64	sys_sched_rr_get_interval	sys_sched_=
rr_get_interval
> +424	common	pidfd_send_signal		sys_pidfd_send_signal
> +425	common	io_uring_setup			sys_io_uring_setup
> +426	common	io_uring_enter			sys_io_uring_enter
> +427	common	io_uring_register		sys_io_uring_register

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

Lightly tested.

The pidfd_test selftest passes.

Ran the io_uring example from fio, which prints lots of:

IOPS 9952, IOS/call2/32, inflight=117 (117), Cachehit=3D0.00%
IOPS 9952, IOS/call2/32, inflight=116 (116), Cachehit=3D0.00%
IOPS 9920, IOS/call2/32, inflight=115 (115), Cachehit=3D0.00%
IOPS 9952, IOS/call2/32, inflight=115 (115), Cachehit=3D0.00%
IOPS 9920, IOS/call2/32, inflight=115 (115), Cachehit=3D0.00%
IOPS 9952, IOS/call2/32, inflight=115 (115), Cachehit=3D0.00%
IOPS!0016, IOS/call2/32, inflight=114 (114), Cachehit=3D0.00%
IOPS!0016, IOS/call2/32, inflight=113 (113), Cachehit=3D0.00%
IOPS!0048, IOS/call2/32, inflight=113 (113), Cachehit=3D0.00%
IOPS!0016, IOS/call2/32, inflight=113 (113), Cachehit=3D0.00%
IOPS!0048, IOS/call2/32, inflight=112 (112), Cachehit=3D0.00%
IOPS!0016, IOS/call2/32, inflight=110 (110), Cachehit=3D0.00%
IOPS!0048, IOS/call2/32, inflight=105 (105), Cachehit=3D0.00%
IOPS!0048, IOS/call2/32, inflight=104 (104), Cachehit=3D0.00%
IOPS!0080, IOS/call2/32, inflight=102 (102), Cachehit=3D0.00%
IOPS!0112, IOS/call2/32, inflight=100 (100), Cachehit=3D0.00%
IOPS!0080, IOS/call2/32, inflight=97 (97), Cachehit=3D0.00%
IOPS!0112, IOS/call2/32, inflight=97 (97), Cachehit=3D0.00%
IOPS!0112, IOS/call2/31, inflight=126 (126), Cachehit=3D0.00%
IOPS!0048, IOS/call2/32, inflight=126 (126), Cachehit=3D0.00%
IOPS!0048, IOS/call2/32, inflight=125 (125), Cachehit=3D0.00%
IOPS!0016, IOS/call2/32, inflight=119 (119), Cachehit=3D0.00%
IOPS!0048, IOS/call2/32, inflight=117 (117), Cachehit=3D0.00%
IOPS!0016, IOS/call2/32, inflight=114 (114), Cachehit=3D0.00%
IOPS!0048, IOS/call2/32, inflight=111 (111), Cachehit=3D0.00%
IOPS!0048, IOS/call2/32, inflight=108 (108), Cachehit=3D0.00%
IOPS!0048, IOS/call2/32, inflight=107 (107), Cachehit=3D0.00%
IOPS!0048, IOS/call2/32, inflight=105 (105), Cachehit=3D0.00%

Which is good I think?


cheers
