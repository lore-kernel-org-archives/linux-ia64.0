From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 26 Oct 2018 22:58:20 +0000
Subject: RE: [PATCH v4 0/5] ia64: system call table generation support
Message-Id: <3908561D78D1C84285E8C5FCA982C28F7D42C7D2@ORSMSX110.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1540530674-3824-1-git-send-email-firoz.khan@linaro.org>
In-Reply-To: <1540530674-3824-1-git-send-email-firoz.khan@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Firoz Khan <firoz.khan@linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>
Cc: "y2038@lists.linaro.org" <y2038@lists.linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>, "deepa.kernel@gmail.com" <deepa.kernel@gmail.com>, "marcin.juszkiewicz@linaro.org" <marcin.juszkiewicz@linaro.org>

> Finally, this is the ground work to solve the Y2038 issue. We need 
> to add two dozen of system calls to solve Y2038 issue. So this patch
> series will help to add new system calls easily by adding new entry 
> in the syscall.tbl.

You have great optimism that anyone will care about ia64 in 2038 :-)

Patches look good now.  If I don't see any comments in the next few
days I'll queue them for next merge window.

Thanks

-Tony
