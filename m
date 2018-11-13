From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 13 Nov 2018 17:09:14 +0000
Subject: RE: [PATCH v5 0/5] ia64: system call table generation support
Message-Id: <3908561D78D1C84285E8C5FCA982C28F7D4560BE@ORSMSX110.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1542092265-20956-1-git-send-email-firoz.khan@linaro.org>
In-Reply-To: <1542092265-20956-1-git-send-email-firoz.khan@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Firoz Khan <firoz.khan@linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>
Cc: "y2038@lists.linaro.org" <y2038@lists.linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>, "deepa.kernel@gmail.com" <deepa.kernel@gmail.com>, "marcin.juszkiewicz@linaro.org" <marcin.juszkiewicz@linaro.org>

> The purpose of this patch series is, we can easily
> add/modify/delete system call table support by cha-
> nging entry in syscall.tbl file instead of manually
> changing many files. The other goal is to unify the
> system call table generation support implementation
> across all the architectures.

Replaced v4 with this new version in my "next" branch.

Thanks

-Tony
