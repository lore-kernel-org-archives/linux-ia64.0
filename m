From: Hanjun Guo <guohanjun@huawei.com>
Date: Thu, 16 Aug 2012 10:28:08 +0000
Subject: Re: [BUGFIX PATCH][RESEND] kexec & iosapic: kexec oops when iosapic was removed
Message-Id: <502CCB38.1030705@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1344583395-9128-1-git-send-email-guohanjun@huawei.com> <5025CD41.2030502@huawei.com> <3908561D78D1C84285E8C5FCA982C28F19375F30@ORSMSX104.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F19375F30@ORSMSX104.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Eric Biederman <ebiederm@xmission.com>, Vivek Goyal <vgoyal@redhat.com>, Haren Myneni <hbabu@us.ibm.com>, Toshi Kani <toshi.kani@hp.com>, Yinghai Lu <yinghai@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>

On 2012/8/13 10:54, Luck, Tony wrote:
>> 		vec = irq_to_vector(irq);
>> 		list_for_each_entry(rte, &info->rtes,
>> 				rte_list) {
>> +			if (rte->refcnt = NO_REF_RTE)
>> +				continue;
>> +
>> 			iosapic_write(rte->iosapic,
>> 					IOSAPIC_RTE_LOW(rte->rte_index),
>> 					IOSAPIC_MASK|vec);
> 
> This will work - but is it papering over a problem when you removed the
> iosapic? Should we really have removed this "rte" from rte_list when the
> iosapic was removed?
> 
> -Tony
> 

Hi Tony,
    Thanks for your comments, and sorry for the late reply.

We only set rte->refcnt to NO_REF_RTE if no device attach to this RTE when
unregister a GSI, and increase the rte->refcnt if the RTE is already existing
when register a GSI, so "rte" will not removed from rte_list when the
iosapic is removed.

Actually, the rte_list will keep static when remove/add a existing iosapic
after boot up.

Should we remove the RTE from the rte_list? if yes, we will have more
to do than this patch.

Thanks
Hanjun Guo

