From: Arnd Bergmann <arnd@arndb.de>
Date: Sun, 31 Mar 2019 16:28:18 +0000
Subject: Re: [PATCH 2/2] arch: add pidfd and io_uring syscalls everywhere
Message-Id: <CAK8P3a14of-jJA2q7rki3gHk6gwE-0TCkzHuXZ1+TkemopgfRA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190325143521.34928-1-arnd@arndb.de>
 <20190325144737.703921-1-arnd@arndb.de>
 <87y34vl6ji.fsf@concordia.ellerman.id.au>
In-Reply-To: <87y34vl6ji.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mips@vger.kernel.org, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, Max Filippov <jcmvbkbc@gmail.com>, Paul Mackerras <paulus@samba.org>, sparclinux <sparclinux@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Helge Deller <deller@gmx.de>, Russell King <linux@armlinux.org.uk>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <catalin.marinas@arm.com>, James Hogan <jhogan@kernel.org>, Firoz Khan <firoz.khan@linaro.org>, Matt Turner <mattst88@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, Will Deacon <will.deacon@arm.com>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Richard Henderson <rth@twiddle.net>, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, Parisc List <linux-parisc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>, alpha <linux-alpha@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, "David S . Miller" <davem@davemloft.net>

On Sun, Mar 31, 2019 at 5:47 PM Michael Ellerman <mpe@ellerman.id.au> wrote:
>
> Arnd Bergmann <arnd@arndb.de> writes:
> > Add the io_uring and pidfd_send_signal system calls to all architectures.
> >
> > These system calls are designed to handle both native and compat tasks,
> > so all entries are the same across architectures, only arm-compat and
> > the generic tale still use an old format.
> >
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > ---
> >  arch/alpha/kernel/syscalls/syscall.tbl      | 4 ++++
> >  arch/arm/tools/syscall.tbl                  | 4 ++++
> >  arch/arm64/include/asm/unistd.h             | 2 +-
> >  arch/arm64/include/asm/unistd32.h           | 8 ++++++++
> >  arch/ia64/kernel/syscalls/syscall.tbl       | 4 ++++
> >  arch/m68k/kernel/syscalls/syscall.tbl       | 4 ++++
> >  arch/microblaze/kernel/syscalls/syscall.tbl | 4 ++++
> >  arch/mips/kernel/syscalls/syscall_n32.tbl   | 4 ++++
> >  arch/mips/kernel/syscalls/syscall_n64.tbl   | 4 ++++
> >  arch/mips/kernel/syscalls/syscall_o32.tbl   | 4 ++++
> >  arch/parisc/kernel/syscalls/syscall.tbl     | 4 ++++
> >  arch/powerpc/kernel/syscalls/syscall.tbl    | 4 ++++
>
> Have you done any testing?
>
> I'd rather not wire up syscalls that have never been tested at all on
> powerpc.

No, I have not. I did review the system calls carefully and added the first
patch to fix the bug on x86 compat mode before adding the same bug
on the other compat architectures though ;-)

Generally, my feeling is that adding system calls is not fundamentally
different from adding other ABIs, and we should really do it at
the same time across all architectures, rather than waiting for each
maintainer to get around to reviewing and testing the new calls
first. This is not a problem on powerpc, but a lot of other architectures
are less active, which is how we have always ended up with
different sets of system calls across architectures.

The problem here is that this makes it harder for the C library to
know when a system call is guaranteed to be available. glibc
still needs a feature test for newly added syscalls to see if they
are working (they might be backported to an older kernel, or
disabled), but whenever the minimum kernel version is increased,
it makes sense to drop those checks and assume non-optional
system calls will work if they were part of that minimum version.

In the future, I'd hope that any new system calls get added
right away on all architectures when they land (it was a bit
tricky this time, because I still did a bunch of reworks that
conflicted with the new calls). Bugs will happen of course, but
I think adding them sooner makes it more likely to catch those
bugs early on so we have a chance to fix them properly,
and need fewer arch specific workarounds (ideally none)
for system calls.

       Arnd
