From: Tejun Heo <tj@kernel.org>
Date: Wed, 23 Sep 2009 02:08:23 +0000
Subject: Re: [PATCH 1/4] vmalloc: rename local variables vmalloc_start and
Message-Id: <4AB98317.9090500@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org> <1253605214-23210-2-git-send-email-tj@kernel.org> <alpine.DEB.1.10.0909221851380.9410@V090114053VZO-1>
In-Reply-To: <alpine.DEB.1.10.0909221851380.9410@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org

Christoph Lameter wrote:
> On Tue, 22 Sep 2009, Tejun Heo wrote:
> 
>>   const unsigned long vmalloc_end = vmalloc_end & ~(align - 1);
>>
>> Rename local variables vmalloc_start and vmalloc_end to vm_start and
>> vm_end to avoid the collision.
> 
> Could you keep vmalloc_end and vmalloc_start? vm_start and vm_end may led
> to misinterpretations as start and end of the memory area covered by the
> VM.

Hmmm... yeah, the right thing to do would be either let ia64 use
VMALLOC_END directly as variable name or let it alias an unlikely
symbol like ____vmalloc_end as macro which ends up expanding to a
seemingly normal symbol like vmalloc_end is just rude.  I'll change
ia64 part.

Thanks.

-- 
tejun
