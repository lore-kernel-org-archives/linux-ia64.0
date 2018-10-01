From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 01 Oct 2018 14:44:16 +0000
Subject: Re: [PATCH v2 1/7] ia64: add __NR_old_getpagesize macro
Message-Id: <CAK8P3a3wLjX2fOpow78O4jNif-2zQvzdDuf_Gz02gxkWZRO4aw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1538057720-3392-1-git-send-email-firoz.khan@linaro.org>
 <1538057720-3392-2-git-send-email-firoz.khan@linaro.org> <CAK8P3a3zhVOymM4--mJ5dfbee3buhp2vw4uxQHgxVoDCDTuR2w@mail.gmail.com>
 <CALxhOnjiKpnON7rGnf5a4Enbj3cTagD4DgvTyt-3XFxXk-Ps+A@mail.gmail.com>
In-Reply-To: <CALxhOnjiKpnON7rGnf5a4Enbj3cTagD4DgvTyt-3XFxXk-Ps+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Firoz Khan <firoz.khan@linaro.org>
Cc: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, gregkh <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, y2038 Mailman List <y2038@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Deepa Dinamani <deepa.kernel@gmail.com>, Marcin Juszkiewicz <marcin.juszkiewicz@linaro.org>

On Mon, Oct 1, 2018 at 4:18 PM Firoz Khan <firoz.khan@linaro.org> wrote:
>
> Hi Arnd,
>
> On Fri, 28 Sep 2018 at 17:41, Arnd Bergmann <arnd@arndb.de> wrote:
> >
> > On Thu, Sep 27, 2018 at 4:16 PM Firoz Khan <firoz.khan@linaro.org> wrote:
> > >
> > > Add __NR_old_getpagesize in order to not break old user space
> > > as it is reserved for backwards compatibility with old __NR_
> > > getpagesize.
> >
> > That description doesn't really make sense here.
>
> Sure I'll some more details. But rest of the patch looks good?
> This is some I was bit confused! In header there is no entry, but
> in system call table has the entry for the system call.

I think adding some macro for it makes sense, and the
__NR_old_getpagesize name you picked is fine for that.

I think generally speaking we want the unistd.h macros to
match up with the system call entry points, and there are
currently multiple ways they diverge:

- System calls have been removed from the kernels, and the
  macros in unistd.h are still there on some architectures but not
  others. This is something we should clean up /after/ you are
  done.

- System calls have a number but are not implemented on all
  architectures because they don't make sense (e.g. pk pkey_add).
  These should probably have an entry in kernel/sys_ni.c if they
  don't already have one.

- System calls have an entry but no macro, like the ia64
  old_getpagesize. I think if you encounter one of these,
  we need to fix them up before your series so we can
  complete the conversion to generated tables.

        Arnd
