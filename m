From: Sudeep Holla <sudeep.holla@arm.com>
Date: Tue, 19 Apr 2016 13:00:05 +0000
Subject: Re: [PATCH v4 1/5] ACPI / processor_idle: introduce ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE
Message-Id: <57162BD5.90006@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201604192041.pUqHza4O%fengguang.wu@intel.com>
In-Reply-To: <201604192041.pUqHza4O%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kbuild test robot <lkp@intel.com>
Cc: Sudeep Holla <sudeep.holla@arm.com>, kbuild-all@01.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Al Stone <al.stone@linaro.org>, Prashanth Prakash <pprakash@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, x86@kernel.org, linux-ia64@vger.kernel.org

Hi,

On 19/04/16 13:49, kbuild test robot wrote:
> Hi,
>
> [auto build test ERROR on pm/linux-next]
> [also build test ERROR on v4.6-rc4 next-20160419]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
>
> url:    https://github.com/0day-ci/linux/commits/Sudeep-Holla/ACPI-processor_idle-Add-ACPI-v6-0-LPI-support/20160419-203500
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm.git linux-next
> config: i386-randconfig-x000-201616 (attached as .config)
> reproduce:
>          # save the attached .config to linux build tree
>          make ARCH=i386
>
> Note: the linux-review/Sudeep-Holla/ACPI-processor_idle-Add-ACPI-v6-0-LPI-support/20160419-203500 HEAD c51fc2a756d7b0dce908a4ca043d1d458c400af5 builds fine.
>        It only hurts bisectibility.
>

Thanks for the report, it's now fixed locally.
It will part of the next version.

--
Regards,
Sudeep
