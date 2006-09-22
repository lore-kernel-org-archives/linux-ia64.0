From: Horms <horms@verge.net.au>
Date: Fri, 22 Sep 2006 07:39:25 +0000
Subject: Re: [Fastboot] [Patch] ia64 Kexec/Kdump patch for 2.6.18
Message-Id: <20060922073923.GF29419@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAC6D88895D68Findou.takao@jp.fujitsu.com>
In-Reply-To: <BAC6D88895D68Findou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 22, 2006 at 01:09:02PM +0900, Horms wrote:
> ia64 Kexec/Kdump patch for 2.6.18
> 
> > ia64 Kexec/Kdump patch for 2.6.18
> > 
> > Fixes since last patch:
> > 
> > 1. Check val in kdump_init_notifier.
> > 2. write EOI to clean in-service flag to make kdump work when crash
> > happen inside irq handler.
> > 3. Make CONFIG_KEXEC and CONFIG_CRASH_DUMP depends on !CONFIG_HP_SIM.
> > 
> > Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
> 
> Incremental version of this patch
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

The entire series, for 2.6.18 and ia64-test is now online at 
http://www.vergenet.net/~horms/patches/ia64-kexec/kernel/

There was a bit of a problem with the up port of ia64-kexec-2.patch,
specifically the "drivers/sn/Kconfig" bits were mucked up,
I have fixed this.

The non-incremental version of ia64-kexec-2.patch was also
a bit bogus in various ways, I have fixed this too.


I have also applied the series to 2.6.18 and published this
as a git tree. I will see how tracking Linus' tree goes from here.
I may also make a branch in there for my own changes.

git://www.kernel.org/pub/scm/linux/kernel/git/horms/kexec-ia64-2.6.git
http://www.kernel.org/git/?p=linux/kernel/git/horms/kexec-ia64-2.6.git;a=summary

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

