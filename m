From: Viresh Kumar <viresh.kumar@linaro.org>
Date: Tue, 02 Apr 2013 00:49:39 +0000
Subject: Re: [PATCH 4/9] ia64: cpufreq: move cpufreq driver to drivers/cpufreq
Message-Id: <CAKohpompxOpwi7fsy1m5UBxymR=dsVra3wvMcvziu7jd9iq8Ow@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1364229828.git.viresh.kumar@linaro.org>
	<afc636963b63becccf34d092203c53369bd1b735.1364229828.git.viresh.kumar@linaro.org>
	<CAKohponax2iDZeA-WG_L2XVHU5GGJB2nSPWVoVxbZUoez1ZpDw@mail.gmail.com>
	<CAKohpokkyQK+650aPLtdXJ0wHWupR=-bcTM_eCoZRDy3N47HJQ@mail.gmail.com>
	<CA+8MBbLwxiPPvyKyQNEDSbNKthpAmooKVe7b+pg-NCETOkSLPA@mail.gmail.com>
In-Reply-To: <CA+8MBbLwxiPPvyKyQNEDSbNKthpAmooKVe7b+pg-NCETOkSLPA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, arvind.chauhan@arm.com, robin.randhawa@arm.com, Steve.Bannister@arm.com, Liviu.Dudau@arm.com, charles.garcia-tobin@arm.com, cpufreq@vger.kernel.org, Linux PM mailing list <linux-pm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linaro-kernel@lists.linaro.org, arnd.bergmann@linaro.org, "Rafael J. Wysocki" <rjw@sisk.pl>

On 2 April 2013 02:52, Tony Luck <tony.luck@gmail.com> wrote:
> [Repost in plain text so the lists don't bounce it - curse you Gmail
> for switching to HTML]

Just to let others know how you fixed it: Above the compose area there
is a small button (or whatever you call it) which can show "Rich Formatting"
or "plain text". Click on that so that it shows "Rich Formatting" all the time.

>> Any comments on this patch?
>
> This part looks OK ... But is there a big finish later in the patch series where
> you unify some/all of the cpufreq code across architectures?  By
> itself just moving
> bits from arch/ia64/kernel/cpufreq to drivers/cpufreq/ doesn't look to add
> much value.

There are people (including me) who tried various times to get things fixed/
consolidated in cpufreq area. They mostly worked over cleaning up stuff inside
drivers/cpufreq area rather then looking at complete kernel. To make that
path easy, this patchset is the first step: "Bring all of them together"..

After this more consolidation work may follow which will span all
cpufreq drivers.
One aspect would be to use cpufreq-cpu0 for whatever platform we can.

For now, your Ack will work :)
