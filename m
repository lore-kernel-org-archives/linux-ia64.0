From: Tony Luck <tony.luck@gmail.com>
Date: Mon, 17 Jun 2013 22:57:28 +0000
Subject: Re: [PATCH -v5 0/8] Add hostbridge resource release to support root bus hotplug in IA64
Message-Id: <CA+8MBb+BSNnLtR8jZinTh9h01f3=Zeu+kX6xke1Ei08HYzRQvg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1370504093-14908-1-git-send-email-wangyijing@huawei.com>
	<20130615002224.GA21643@google.com>
	<51BE7AD5.5010300@huawei.com>
In-Reply-To: <51BE7AD5.5010300@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Yinghai Lu <yinghai@kernel.org>, linux-pci@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Liu Jiang <jiang.liu@huawei.com>

On Sun, Jun 16, 2013 at 7:56 PM, Yijing Wang <wangyijing@huawei.com> wrote:
>> Tony, what do you think about this?  It only touches ia64, and I
>> have no way to build or test it.  So maybe you should handle this?
>>
>> I haven't reviewed it, but I think it's the right general direction,
>> at least.
>>
> Bjorn, thanks for your comments!
>
> Hi Tony, this series mainly to make pci root bus hotplug happy in IA64.
> I cannot test the first two patch(SGI related) in my IA64 machine.
> But the rest patches has been tested in my ia64 machine, and result is ok.

I'd like to understand the dependencies on Bjorn's pci-next tree.  If
this series
actually only depends on Linus' v3.10-rc6 I'd rather start from there (because
then I don't need to coordinate "please-pull" messages when sending things
to Linus).  If we really do need things from the pci-next tree, well that's OK
too, but I'd still like to know what they are.

-Tony
