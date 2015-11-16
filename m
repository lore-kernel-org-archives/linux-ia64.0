From: Tejun Heo <tj@kernel.org>
Date: Mon, 16 Nov 2015 15:55:06 +0000
Subject: Re: [PATCH v2] percpu: remove PERCPU_ENOUGH_ROOM which is stale definition
Message-Id: <20151116155506.GC18894@mtj.duckdns.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1446643567-2250-1-git-send-email-jungseoklee85@gmail.com>
In-Reply-To: <1446643567-2250-1-git-send-email-jungseoklee85@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jungseok Lee <jungseoklee85@gmail.com>
Cc: cl@linux.com, tony.luck@intel.com, fenghua.yu@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Nov 04, 2015 at 01:26:07PM +0000, Jungseok Lee wrote:
> As pure cleanup, this patch removes PERCPU_ENOUGH_ROOM which is not
> used any more. That is, no code refers to the definition.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>

Applied to percpu/for-4.5.

Thanks.

-- 
tejun
