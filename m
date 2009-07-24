From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Fri, 24 Jul 2009 05:07:15 +0000
Subject: RE: [RFC PATCH] ia64: convert to dynamic percpu allocator
Message-Id: <A6AD88C3F2289247BE726C37303E1EB8B0A9115B@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4A65B0AB.5000608@kernel.org>
 <A6AD88C3F2289247BE726C37303E1EB8B097D4C5@orsmsx505.amr.corp.intel.com>
 <4A663DC7.4060600@kernel.org>
In-Reply-To: <4A663DC7.4060600@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Tejun Heo' <tj@kernel.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, 'lkml' <linux-kernel@vger.kernel.org>, "'linux-arch@vger.kernel.org'" <linux-arch@vger.kernel.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>

>Yu, Fenghua wrote:
>>> This patch is available in the following git tree.
>>>
>>>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu.git review-ia64
>>
>> Is this patch against the latest linux-next? It's applied cleanly on
>> linux-next. But compilation reports undefined function
>> pcpu_alloc_alloc_info() in both contig.c and discontig.c.
>
>Oh, it's on top of percpu#for-next + 20 patches to implement sparse
>embedding[1].  I think it would be the easiest to fetch the above git
>tree.

After cloning from git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu.git, kernel built with CONFIG_DISCONTIGMEM=y boots ok.

After pulling from review-ia64, kernel built with CONFIG_DISCONTIGMEM=y can not boot on ia64. After loading kernel and initrd, system hangs and doesn't show anything on serial port.

Thanks.

-Fenghua 
