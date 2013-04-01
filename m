From: Tony Luck <tony.luck@gmail.com>
Date: Mon, 01 Apr 2013 21:22:53 +0000
Subject: Re: [PATCH 4/9] ia64: cpufreq: move cpufreq driver to drivers/cpufreq
Message-Id: <CA+8MBbLwxiPPvyKyQNEDSbNKthpAmooKVe7b+pg-NCETOkSLPA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1364229828.git.viresh.kumar@linaro.org>
	<afc636963b63becccf34d092203c53369bd1b735.1364229828.git.viresh.kumar@linaro.org>
	<CAKohponax2iDZeA-WG_L2XVHU5GGJB2nSPWVoVxbZUoez1ZpDw@mail.gmail.com>
	<CAKohpokkyQK+650aPLtdXJ0wHWupR=-bcTM_eCoZRDy3N47HJQ@mail.gmail.com>
In-Reply-To: <CAKohpokkyQK+650aPLtdXJ0wHWupR=-bcTM_eCoZRDy3N47HJQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, arvind.chauhan@arm.com, robin.randhawa@arm.com, Steve.Bannister@arm.com, Liviu.Dudau@arm.com, charles.garcia-tobin@arm.com, cpufreq@vger.kernel.org, Linux PM mailing list <linux-pm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linaro-kernel@lists.linaro.org, arnd.bergmann@linaro.org, "Rafael J. Wysocki" <rjw@sisk.pl>

[Repost in plain text so the lists don't bounce it - curse you Gmail
for switching to HTML]

> Any comments on this patch?

This part looks OK ... But is there a big finish later in the patch series where
you unify some/all of the cpufreq code across architectures?  By
itself just moving
bits from arch/ia64/kernel/cpufreq to drivers/cpufreq/ doesn't look to add
much value.

-Tony
