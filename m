From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Fri, 02 Dec 2016 09:55:32 +0000
Subject: Re: [PATCH v2] ia64: move cacheinfo sysfs to generic cacheinfo infrastructure
Message-Id: <3a707749-4737-1dd3-fce2-c1968762de38@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1480604118-12037-1-git-send-email-sudeep.holla@arm.com>
 <1480604939-11114-1-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1480604939-11114-1-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sudeep Holla <sudeep.holla@arm.com>, linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On 2016/12/1 23:08, Sudeep Holla wrote:
> This patch removes the redundant sysfs cacheinfo code by reusing
> the recently introduced generic cacheinfo infrastructure through the
> commit 246246cbde5e ("drivers: base: support cpu cache information
> interface to userspace via sysfs")
>
> Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Hanjun Guo <hanjun.guo@linaro.org>
> Cc: linux-ia64@vger.kernel.org
> ---
>  arch/ia64/kernel/topology.c | 384 ++++++++++++++------------------------------
>  1 file changed, 117 insertions(+), 267 deletions(-)
>
> v1->v2:
> 	- Rebased on top -next that has a patch introducing
> 	  cpu_map_populated
> 	- Also added SMP related macros that I missed in v1
> Hi,
>
> This is repost of the patch that was posted before several times to
> remove duplicate code. Since I don't have the platform to test, I was
> hoping to get some testing. This time Hanjun has kindly agreed to do
> some testing. Thanks a lot Hanjun in advance. You need to base this on
> top linux-next as there are few patches there. Take your time as this is
> not urgent at all.

You are welcome, I will test it next week :)

Thanks
Hanjun
