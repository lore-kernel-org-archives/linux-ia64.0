From: Christoph Lameter <cl@linux-foundation.org>
Date: Thu, 29 Oct 2009 14:49:17 +0000
Subject: Re: [PATCH percpu#for-next] ia64: add sparse annotation to
Message-Id: <alpine.DEB.1.10.0910291444240.18197@V090114053VZO-1>
List-Id: <linux-ia64.vger.kernel.org>
References: <4AE9A0B3.4010305@kernel.org>
In-Reply-To: <4AE9A0B3.4010305@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>

On Thu, 29 Oct 2009, Tejun Heo wrote:

> ia64 has its own optimized percpu accessor - __ia64_per_cpu_var().
> Add percpu sparse annotations to it.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
