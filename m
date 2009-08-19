From: Tejun Heo <tj@kernel.org>
Date: Wed, 19 Aug 2009 14:36:21 +0000
Subject: Re: [RFC PATCH] ia64: convert to dynamic percpu allocator
Message-Id: <4A8C0DE5.302@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4A65B0AB.5000608@kernel.org> <A6AD88C3F2289247BE726C37303E1EB8B097D4C5@orsmsx505.amr.corp.intel.com> <4A663DC7.4060600@kernel.org> <A6AD88C3F2289247BE726C37303E1EB8B0A9115B@orsmsx505.amr.corp.intel.com> <4A695897.2020902@kernel.org> <A6AD88C3F2289247BE726C37303E1EB8B3A85355@orsmsx505.amr.corp.intel.com> <4A826785.4000509@kernel.org>
In-Reply-To: <4A826785.4000509@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, 'lkml' <linux-kernel@vger.kernel.org>, "'linux-arch@vger.kernel.org'" <linux-arch@vger.kernel.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>

Tejun Heo wrote:
> * Is ai->reserved_size necessary for ia64?  This is necessary if
>   there's linking range restriction when loading modules.
>   ai->reserved_size guarantees that all static module percpu variables
>   are allocated in the first chunk which will be in the linear address
>   range and very close to __per_cpu_start.  If ai->reserved_size is
>   not set, these areas are likely to end up high in the vmalloc area.
> 
>   For example, x86_64 assumes 32bit relocations should be enough to
>   link module symbols and thus needs to set reserved_size but x86_32
>   can link to the whole 32bit space and thus can leave reserved_size
>   at zero.
> 
> * After determining the above, we can set ai->dyn_size to be
> 
>   ai->dyn_size = min(ai->unit_size - ai->static_size - ai->reserved_size,
> 		     PERCPU_DYNAMIC_RESERVE);
> 
> Would the above work?
> 
>> Even with the above PAGE_SIZE changes, the kernel still reports
>> warning from 952: WARN_ON(chunk->immutable) and then panic.
> 
> Hah... strange.  Can you please attach full boot log?  This is
> dicontig configuration, right?

Any news?

Thanks.

-- 
tejun
