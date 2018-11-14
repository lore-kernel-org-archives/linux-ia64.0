From: Firoz Khan <firoz.khan@linaro.org>
Date: Wed, 14 Nov 2018 04:57:34 +0000
Subject: Re: [PATCH v5 0/5] ia64: system call table generation support
Message-Id: <CALxhOngSrDmg12W9zMEgNWakKUK_W9wOv0d2MQ0pmixOs-Ns1w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1542092265-20956-1-git-send-email-firoz.khan@linaro.org> <3908561D78D1C84285E8C5FCA982C28F7D4560BE@ORSMSX110.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7D4560BE@ORSMSX110.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, y2038 Mailman List <y2038@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Deepa Dinamani <deepa.kernel@gmail.com>, Marcin Juszkiewicz <marcin.juszkiewicz@linaro.org>

Hi Tony,

On Tue, 13 Nov 2018 at 22:39, Luck, Tony <tony.luck@intel.com> wrote:
>
> > The purpose of this patch series is, we can easily
> > add/modify/delete system call table support by cha-
> > nging entry in syscall.tbl file instead of manually
> > changing many files. The other goal is to unify the
> > system call table generation support implementation
> > across all the architectures.
>
> Replaced v4 with this new version in my "next" branch.

Ok. Thanks!

Firoz

>
> Thanks
>
> -Tony
