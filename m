From: Firoz Khan <firoz.khan@linaro.org>
Date: Sat, 27 Oct 2018 13:20:59 +0000
Subject: Re: [PATCH v4 0/5] ia64: system call table generation support
Message-Id: <CALxhOniEXwznjhYbAAM3-QR7PjSYvbHVZa798OUa3hu_PKj8Cw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1540530674-3824-1-git-send-email-firoz.khan@linaro.org> <3908561D78D1C84285E8C5FCA982C28F7D42C7D2@ORSMSX110.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7D42C7D2@ORSMSX110.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, y2038 Mailman List <y2038@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Deepa Dinamani <deepa.kernel@gmail.com>, Marcin Juszkiewicz <marcin.juszkiewicz@linaro.org>

Hi Tony,

On Sat, 27 Oct 2018 at 04:28, Luck, Tony <tony.luck@intel.com> wrote:
>
> > Finally, this is the ground work to solve the Y2038 issue. We need
> > to add two dozen of system calls to solve Y2038 issue. So this patch
> > series will help to add new system calls easily by adding new entry
> > in the syscall.tbl.
>
> You have great optimism that anyone will care about ia64 in 2038 :-)
>
> Patches look good now.  If I don't see any comments in the next few
> days I'll queue them for next merge window.

Sounds good. Thanks for your support!

Firoz

>
> Thanks
>
> -Tony
