From: Florian Weimer <fweimer@redhat.com>
Date: Tue, 09 Jun 2020 13:52:17 +0000
Subject: Re: Add a new fchmodat4() syscall, v2
Message-Id: <87o8pscpny.fsf@oldenburg2.str.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190717012719.5524-1-palmer@sifive.com>
In-Reply-To: <20190717012719.5524-1-palmer@sifive.com> (Palmer Dabbelt's
        message of "Tue, 16 Jul 2019 18:27:15 -0700")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Palmer Dabbelt <palmer@sifive.com>
Cc: viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux@armlinux.org.uk, catalin.marinas@arm.com, will@kernel.org, tony.luck@intel.com, fenghua.yu@intel.com, geert@linux-m68k.org, monstr@monstr.eu, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, James.Bottomley@HansenPartnership.com, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, heiko.carstens@de.ibm.com, gor@linux.ibm.com, borntraeger@de.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, luto@kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, x86@kernel.org, peterz@infradead.org, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, dhowells@redhat.com, firoz.khan@linaro.org, stefan@agner.ch, schwidefsky@de.ibm.com, axboe@kernel.dk, christian@brauner.io, hare@suse.com, deepa.kernel@gmail.com, tycho@tycho.ws, kim.phillips@arm.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

* Palmer Dabbelt:

> This patch set adds fchmodat4(), a new syscall. The actual
> implementation is super simple: essentially it's just the same as
> fchmodat(), but LOOKUP_FOLLOW is conditionally set based on the flags.
> I've attempted to make this match "man 2 fchmodat" as closely as
> possible, which says EINVAL is returned for invalid flags (as opposed to
> ENOTSUPP, which is currently returned by glibc for AT_SYMLINK_NOFOLLOW).
> I have a sketch of a glibc patch that I haven't even compiled yet, but
> seems fairly straight-forward:

What's the status here?  We'd really like to see this system call in the
kernel because our emulation in glibc has its problems (especially if
/proc is not mounted).

Thanks,
Florian
