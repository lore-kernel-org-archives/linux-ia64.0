From: Muchun Song <songmuchun@bytedance.com>
Date: Fri, 29 Apr 2022 11:44:14 +0000
Subject: Re: [PATCH v4] mm: Using for_each_online_node and node_online instead of open coding
Message-Id: <YmvPjnjufx+XZxN3@FVFYT0MHHV2J.usts.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220413032915.251254-4-liupeng256@huawei.com>
 <20220429030218.644635-1-liupeng256@huawei.com>
In-Reply-To: <20220429030218.644635-1-liupeng256@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peng Liu <liupeng256@huawei.com>
Cc: mike.kravetz@oracle.com, david@redhat.com, akpm@linux-foundation.org, yaozhenguo1@gmail.com, baolin.wang@linux.alibaba.com, liuyuntao10@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wangkefeng.wang@huawei.com, dave@stgolabs.net, wangborong@cdjrlc.com, linux-ia64@vger.kernel.org, adobriyan@gmail.com

On Fri, Apr 29, 2022 at 03:02:18AM +0000, Peng Liu wrote:
> Use more generic functions to deal with issues related to online
> nodes. The changes will make the code simplified.
> 
> Signed-off-by: Peng Liu <liupeng256@huawei.com>
> Suggested-by: Davidlohr Bueso <dave@stgolabs.net>
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>

Reviewed-by: Muchun Song <songmuchun@bytedance.com>

Thanks.
