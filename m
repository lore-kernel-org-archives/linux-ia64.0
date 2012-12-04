From: Tang Chen <tangchen@cn.fujitsu.com>
Date: Tue, 04 Dec 2012 10:31:16 +0000
Subject: Re: [Patch v4 03/12] memory-hotplug: remove redundant codes
Message-Id: <50BDD0F4.8040806@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com> <1354010422-19648-4-git-send-email-wency@cn.fujitsu.com> <50BDC0DE.4010103@cn.fujitsu.com>
In-Reply-To: <50BDC0DE.4010103@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>

On 12/04/2012 05:22 PM, Tang Chen wrote:
> On 11/27/2012 06:00 PM, Wen Congyang wrote:
>> offlining memory blocks and checking whether memory blocks are offlined
>> are very similar. This patch introduces a new function to remove
>> redundant codes.
>>
>> CC: David Rientjes<rientjes@google.com>
>> CC: Jiang Liu<liuj97@gmail.com>
>> CC: Len Brown<len.brown@intel.com>
>> CC: Christoph Lameter<cl@linux.com>
>> Cc: Minchan Kim<minchan.kim@gmail.com>
>> CC: Andrew Morton<akpm@linux-foundation.org>
>> CC: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>> CC: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
>> Signed-off-by: Wen Congyang<wency@cn.fujitsu.com>
>
> Can we merge this patch with [PATCH 03/12] ?

Sorry, I think we can merge this patch into [PATCH 02/12].
Thanks. :)

>
> Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
>
