From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 06 Jun 2013 07:32:12 +0000
Subject: Re: [PATCH -v4 0/8] Add hostbridge resource release to support root bus hotplug in IA64
Message-Id: <51B03AFC.5060807@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1370412117-12860-1-git-send-email-wangyijing@huawei.com> <CAErSpo5+rj_47kvy1shG0jjRuo5t2zWu5RHqGragxPoBDMVXtg@mail.gmail.com>
In-Reply-To: <CAErSpo5+rj_47kvy1shG0jjRuo5t2zWu5RHqGragxPoBDMVXtg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Yinghai Lu <yinghai@kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <jiang.liu@huawei.com>

Hi Bjorn,
   This series is based your pci-next branch, I used stgit to format this series, I try to
git am them to pci-next, but indeed patch 4 was applied fail, it's strange.
Now I use git format-patch to format this series again, tag v5, and test them in pci-next, result is ok.

Thanks!
Yijing.

On 2013/6/6 1:27, Bjorn Helgaas wrote:
> On Wed, Jun 5, 2013 at 12:01 AM, Yijing Wang <wangyijing@huawei.com> wrote:
>> v3->v4: fix memory allocation problem and use dev_err instead of pr_err follow Bjorn's suggestion.
> 
> What does this series apply to?  I normally apply patches to topic
> branches based on -rc1, but these don't apply cleanly to either
> v3.10-rc1 or to the next-20130605 linux-next tree.
> 
> Bjorn
> 
> 


-- 
Thanks!
Yijing

