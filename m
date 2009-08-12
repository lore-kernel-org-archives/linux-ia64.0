From: Tejun Heo <tj@kernel.org>
Date: Wed, 12 Aug 2009 06:56:05 +0000
Subject: Re: [RFC PATCH] ia64: convert to dynamic percpu allocator
Message-Id: <4A826785.4000509@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4A65B0AB.5000608@kernel.org> <A6AD88C3F2289247BE726C37303E1EB8B097D4C5@orsmsx505.amr.corp.intel.com> <4A663DC7.4060600@kernel.org> <A6AD88C3F2289247BE726C37303E1EB8B0A9115B@orsmsx505.amr.corp.intel.com> <4A695897.2020902@kernel.org> <A6AD88C3F2289247BE726C37303E1EB8B3A85355@orsmsx505.amr.corp.intel.com>
In-Reply-To: <A6AD88C3F2289247BE726C37303E1EB8B3A85355@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, 'lkml' <linux-kernel@vger.kernel.org>, "'linux-arch@vger.kernel.org'" <linux-arch@vger.kernel.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>

Yu, Fenghua wrote:
>> Yu, Fenghua wrote:
>>
>>> After cloning from
>>> git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu.git, kernel
>>> built with CONFIG_DISCONTIGMEM=y boots ok.
>>>
>>> After pulling from review-ia64, kernel built with
>>> CONFIG_DISCONTIGMEM=y can not boot on ia64. After loading kernel and
>>> initrd, system hangs and doesn't show anything on serial port.
>> Heh, I didn't really expect it to work that easily either.  The code
>> builds but is completely untested (I can't test them).  Can you try to
>> track it down?  Serial console should be up and running at that point,
>> no?
>>
>> Thanks.
> 
> IA64 kernel boots hit this in mm/percpu.c
> BUG_ON(ai->unit_size < size_sum);
> ai->unit_size is PERCPU_PAGE_SIZE which is 64K on IA64. size_sum is
> relatively smaller than 64K.
> 
> Will you define PERCPU_DYNAMIC_RESERVE and PERCPU_MODULE_RESERVE as
> PAGE_SIZE or the bigger one between the current definition and
> PAGE_SIZE?

Hmmm...

* Is ai->reserved_size necessary for ia64?  This is necessary if
  there's linking range restriction when loading modules.
  ai->reserved_size guarantees that all static module percpu variables
  are allocated in the first chunk which will be in the linear address
  range and very close to __per_cpu_start.  If ai->reserved_size is
  not set, these areas are likely to end up high in the vmalloc area.

  For example, x86_64 assumes 32bit relocations should be enough to
  link module symbols and thus needs to set reserved_size but x86_32
  can link to the whole 32bit space and thus can leave reserved_size
  at zero.

* After determining the above, we can set ai->dyn_size to be

  ai->dyn_size = min(ai->unit_size - ai->static_size - ai->reserved_size,
		     PERCPU_DYNAMIC_RESERVE);

Would the above work?

> Even with the above PAGE_SIZE changes, the kernel still reports
> warning from 952: WARN_ON(chunk->immutable) and then panic.

Hah... strange.  Can you please attach full boot log?  This is
dicontig configuration, right?

Thanks.

-- 
tejun
