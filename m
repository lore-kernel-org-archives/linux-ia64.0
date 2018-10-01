From: Firoz Khan <firoz.khan@linaro.org>
Date: Mon, 01 Oct 2018 14:27:54 +0000
Subject: Re: [PATCH v2 6/7] ia64: uapi header and system call table file generation
Message-Id: <CALxhOnjrjF1XuwGd_F5xFz97noTvebhzdCvN51v93zOTuQqDiA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1538057720-3392-1-git-send-email-firoz.khan@linaro.org>
 <1538057720-3392-7-git-send-email-firoz.khan@linaro.org> <CAK8P3a3YkR7Qr=XnqvQTOn=v34rCBfW1+dqU5xpV4ysar+C4yg@mail.gmail.com>
In-Reply-To: <CAK8P3a3YkR7Qr=XnqvQTOn=v34rCBfW1+dqU5xpV4ysar+C4yg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, y2038 Mailman List <y2038@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, Deepa Dinamani <deepa.kernel@gmail.com>, Marcin Juszkiewicz <marcin.juszkiewicz@linaro.org>

Hi Arnd,

On Fri, 28 Sep 2018 at 17:40, Arnd Bergmann <arnd@arndb.de> wrote:
>
> On Thu, Sep 27, 2018 at 4:16 PM Firoz Khan <firoz.khan@linaro.org> wrote:
>
> > +#include <asm/syscall_table.h>
> >         .org sys_call_table + 8*NR_syscalls     // guard against failures to increase NR_syscalls
> > +#undef __SYSCALL
>
> This part looks odd: according to the comment, this should only guard against
> the table getting out of sync. However, with the script, that will never happen.

Thanks for pointing it out this error.

- Firoz
>
>       Arnd
