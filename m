From: Jungseok Lee <jungseoklee85@gmail.com>
Date: Tue, 17 Nov 2015 12:25:10 +0000
Subject: Re: [PATCH v2] percpu: remove PERCPU_ENOUGH_ROOM which is stale definition
Message-Id: <7ECE283C-7EC8-4E17-98C5-F4895F17A2DC@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1446643567-2250-1-git-send-email-jungseoklee85@gmail.com> <20151116155506.GC18894@mtj.duckdns.org>
In-Reply-To: <20151116155506.GC18894@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, tony.luck@intel.com, fenghua.yu@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Nov 17, 2015, at 12:55 AM, Tejun Heo wrote:

Dear Tejun,

> On Wed, Nov 04, 2015 at 01:26:07PM +0000, Jungseok Lee wrote:
>> As pure cleanup, this patch removes PERCPU_ENOUGH_ROOM which is not
>> used any more. That is, no code refers to the definition.
>> 
>> Acked-by: Christoph Lameter <cl@linux.com>
>> Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>
> 
> Applied to percpu/for-4.5.

I don't know how to handle this one as not getting feedbacks from ia64
side. Thanks for taking caring of this one!

Best Regards
Jungseok Lee
