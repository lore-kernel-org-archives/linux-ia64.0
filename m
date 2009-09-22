From: Christoph Lameter <cl@linux-foundation.org>
Date: Tue, 22 Sep 2009 22:52:31 +0000
Subject: Re: [PATCH 1/4] vmalloc: rename local variables vmalloc_start and
Message-Id: <alpine.DEB.1.10.0909221851380.9410@V090114053VZO-1>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org> <1253605214-23210-2-git-send-email-tj@kernel.org>
In-Reply-To: <1253605214-23210-2-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org

On Tue, 22 Sep 2009, Tejun Heo wrote:

>   const unsigned long vmalloc_end = vmalloc_end & ~(align - 1);
>
> Rename local variables vmalloc_start and vmalloc_end to vm_start and
> vm_end to avoid the collision.

Could you keep vmalloc_end and vmalloc_start? vm_start and vm_end may led
to misinterpretations as start and end of the memory area covered by the
VM.

