From: Firoz Khan <firoz.khan@linaro.org>
Date: Mon, 01 Oct 2018 14:30:37 +0000
Subject: Re: [PATCH v2 1/7] ia64: add __NR_old_getpagesize macro
Message-Id: <CALxhOnjiKpnON7rGnf5a4Enbj3cTagD4DgvTyt-3XFxXk-Ps+A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1538057720-3392-1-git-send-email-firoz.khan@linaro.org>
 <1538057720-3392-2-git-send-email-firoz.khan@linaro.org> <CAK8P3a3zhVOymM4--mJ5dfbee3buhp2vw4uxQHgxVoDCDTuR2w@mail.gmail.com>
In-Reply-To: <CAK8P3a3zhVOymM4--mJ5dfbee3buhp2vw4uxQHgxVoDCDTuR2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, y2038 Mailman List <y2038@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, Deepa Dinamani <deepa.kernel@gmail.com>, Marcin Juszkiewicz <marcin.juszkiewicz@linaro.org>

Hi Arnd,

On Fri, 28 Sep 2018 at 17:41, Arnd Bergmann <arnd@arndb.de> wrote:
>
> On Thu, Sep 27, 2018 at 4:16 PM Firoz Khan <firoz.khan@linaro.org> wrote:
> >
> > Add __NR_old_getpagesize in order to not break old user space
> > as it is reserved for backwards compatibility with old __NR_
> > getpagesize.
>
> That description doesn't really make sense here.

Sure I'll some more details. But rest of the patch looks good?
This is some I was bit confused! In header there is no entry, but
in system call table has the entry for the system call.

- Firoz

>
>         Arnd
