From: Bernhard Walle <bwalle@suse.de>
Date: Tue, 13 Feb 2007 17:25:34 +0000
Subject: Re: Zero size /proc/vmcore on ia64
Message-Id: <20070213172534.GB21980@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070205015901.GA31446@verge.net.au>
In-Reply-To: <20070205015901.GA31446@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

* Zou Nan hai <nanhai.zou@intel.com> [2007-02-08 05:21]:
>
> 	This is reasonable.
> 	So please apply the following patch to make saved_max_pfn point to
> max_pfn of entire system.

So, as the patch works here also and it's necessary to make kdump
working, I suggest including it mainline.


Regards,
Bernhard

