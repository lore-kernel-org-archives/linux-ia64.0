From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 12 Oct 2018 19:40:41 +0000
Subject: Re: [PATCH v3 0/7] ia64: system call table generation support
Message-Id: <CAK8P3a2uMx8eAa+WAGtePA3O=U_LXXBP7XX62fAO9g1NfpXgNQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1539231895-4118-1-git-send-email-firoz.khan@linaro.org>
 <3908561D78D1C84285E8C5FCA982C28F7D40F9DD@ORSMSX107.amr.corp.intel.com>
 <CALxhOngtGNP7MATzwtMZd_Xw+rqvdhP9NMtTxwCEgmzayZshOQ@mail.gmail.com> <3908561D78D1C84285E8C5FCA982C28F7D410C05@ORSMSX107.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7D410C05@ORSMSX107.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Firoz Khan <firoz.khan@linaro.org>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, gregkh <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, y2038 Mailman List <y2038@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Deepa Dinamani <deepa.kernel@gmail.com>, Marcin Juszkiewicz <marcin.juszkiewicz@linaro.org>

On Fri, Oct 12, 2018 at 6:12 PM Luck, Tony <tony.luck@intel.com> wrote:
>
> > I suspect the offset logic in the system call generation script had a bug. That
> > I fixed it in this patch series.
> >
> > Arnd and Eugene had shared few comments on adding new system call entry in the
> > table and some other things. Appreciate if you can review this patch
> > series so I can
> > finalize system call table implementation for ia64 architecture.
>
> The net effect of these is just to make it easier to add new system calls. Just
> edit the table, instead of editing entry.S and unistd.h picking the next number
> (and remembering to increase  the NR_syscalls). Right?

The driving factor here is the addition of the new y2038 syscalls for 32-bit
architectures that we want to add everywhere at the same time. ia64
and alpha are obviously not affected by this as they are 64-bit only,
but to do it right, we should do all architectures together.

Another point is overall maintainability: it is very time-consuming and
error-prone to find out which architectures in which kernel version support
a specific system call or don't support it. Having a consistent way to
work on the tables should make this is a simple 'git grep'.

> I'm currently baffled at which linker magic makes the unsupported system
> calls alias to sys_ni_syscall.

This is the same method that x86, arm, and s390 have been using
for a while, by sorting the numbers and filling in the missing ones
in the script.

> I'm also uncertain whether allocating system call numbers and creating
> entry points for all the unsupported syscalls is the right thing to do. Might
> that puzzle and frustrate folks whose applications build, but then fail at
> run-time with -ENOSYS.

Again, we want this to be handled consistently across architectures
more than anything. At the moment, we have some architectures that
simply assign a number for each syscall added to x86, while others
don't. Similarly, some architectures drop the entries from unistd.h
if a syscall gets removed from the kernel, and others keep them.

I care less about which way we decide to go here, but I want it to
be done the same way for all architectures.

      Arnd
