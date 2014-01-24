From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 24 Jan 2014 17:33:47 +0000
Subject: Re: [PATCH 0/5] ia64 ski emulator patches
Message-Id: <alpine.LRH.2.02.1401241232090.23466@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LRH.2.02.1401232041520.16873@file01.intranet.prod.int.rdu2.redhat.com> <21218.28095.779306.523187@gargle.gargle.HOWL>
In-Reply-To: <21218.28095.779306.523187@gargle.gargle.HOWL>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mikael Pettersson <mikpelinux@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org



On Fri, 24 Jan 2014, Mikael Pettersson wrote:

> Mikulas Patocka writes:
>  > Hi
>  > 
>  > Here I'm sending some ia64 patches to make it work in the ski emulator. 
>  > This has been broken for a long time.
> 
> Thanks.  I've recently started running 3.x kernels on ia64 via ski,
> but I'm getting random kernel crashes with 3.13.  I'll give your
> patches a try shortly.

BTW. does the kernel boot for you without that _STK_LIM_MAX change? For 
me, _STK_LIM_MAX was a showstopper, it wasn't able to spawn any userspace 
process without this patch.

Mikulkas
