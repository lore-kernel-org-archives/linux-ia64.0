From: Firoz Khan <firoz.khan@linaro.org>
Date: Fri, 12 Oct 2018 04:13:30 +0000
Subject: Re: [PATCH v3 0/7] ia64: system call table generation support
Message-Id: <CALxhOngtGNP7MATzwtMZd_Xw+rqvdhP9NMtTxwCEgmzayZshOQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1539231895-4118-1-git-send-email-firoz.khan@linaro.org> <3908561D78D1C84285E8C5FCA982C28F7D40F9DD@ORSMSX107.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7D40F9DD@ORSMSX107.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, y2038 Mailman List <y2038@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Deepa Dinamani <deepa.kernel@gmail.com>, Marcin Juszkiewicz <marcin.juszkiewicz@linaro.org>

Hi Tony,

On Thu, 11 Oct 2018 at 22:59, Luck, Tony <tony.luck@intel.com> wrote:
>
> Third time lucky. This series boots without any obvious errors on my ia64 machine.

Great! Thanks for your support!

>
> That's not and Ack or Review ... I just applied, compiled and booted.

I suspect the offset logic in the system call generation script had a bug. That
I fixed it in this patch series.

Arnd and Eugene had shared few comments on adding new system call entry in the
table and some other things. Appreciate if you can review this patch
series so I can
finalize system call table implementation for ia64 architecture.

Firoz

>
> -Tony
