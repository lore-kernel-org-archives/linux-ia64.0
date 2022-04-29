From: David Hildenbrand <david@redhat.com>
Date: Fri, 29 Apr 2022 09:29:30 +0000
Subject: Re: [PATCH v4] mm: Using for_each_online_node and node_online instead of open coding
Message-Id: <95216c6f-0614-cadc-d256-92a172d8b8cd@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220413032915.251254-4-liupeng256@huawei.com>
 <20220429030218.644635-1-liupeng256@huawei.com>
In-Reply-To: <20220429030218.644635-1-liupeng256@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peng Liu <liupeng256@huawei.com>, mike.kravetz@oracle.com, akpm@linux-foundation.org, yaozhenguo1@gmail.com, baolin.wang@linux.alibaba.com, songmuchun@bytedance.com, liuyuntao10@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wangkefeng.wang@huawei.com, dave@stgolabs.net, wangborong@cdjrlc.com, linux-ia64@vger.kernel.org, adobriyan@gmail.com

On 29.04.22 05:02, Peng Liu wrote:
> Use more generic functions to deal with issues related to online
> nodes. The changes will make the code simplified.
> 
> Signed-off-by: Peng Liu <liupeng256@huawei.com>
> Suggested-by: Davidlohr Bueso <dave@stgolabs.net>
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> ---

Reviewed-by: David Hildenbrand <david@redhat.com>


-- 
Thanks,

David / dhildenb
