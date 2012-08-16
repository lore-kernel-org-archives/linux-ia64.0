From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 16 Aug 2012 19:33:17 +0000
Subject: Re: [BUGFIX PATCH][RESEND] kexec & iosapic: kexec oops when iosapic was removed
Message-Id: <1345145597.4732.21.camel@misato.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1344583395-9128-1-git-send-email-guohanjun@huawei.com>
	 <5025CD41.2030502@huawei.com>
	 <3908561D78D1C84285E8C5FCA982C28F19375F30@ORSMSX104.amr.corp.intel.com>
	 <502CCB38.1030705@huawei.com>
In-Reply-To: <502CCB38.1030705@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hanjun Guo <guohanjun@huawei.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Eric Biederman <ebiederm@xmission.com>, Vivek Goyal <vgoyal@redhat.com>, Haren Myneni <hbabu@us.ibm.com>, Yinghai Lu <yinghai@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>

On Thu, 2012-08-16 at 18:28 +0800, Hanjun Guo wrote:
> On 2012/8/13 10:54, Luck, Tony wrote:
> >> 		vec = irq_to_vector(irq);
> >> 		list_for_each_entry(rte, &info->rtes,
> >> 				rte_list) {
> >> +			if (rte->refcnt = NO_REF_RTE)
> >> +				continue;
> >> +
> >> 			iosapic_write(rte->iosapic,
> >> 					IOSAPIC_RTE_LOW(rte->rte_index),
> >> 					IOSAPIC_MASK|vec);
> > 
> > This will work - but is it papering over a problem when you removed the
> > iosapic? Should we really have removed this "rte" from rte_list when the
> > iosapic was removed?
> > 
> > -Tony
> > 
> 
> Hi Tony,
>     Thanks for your comments, and sorry for the late reply.
> 
> We only set rte->refcnt to NO_REF_RTE if no device attach to this RTE when
> unregister a GSI, and increase the rte->refcnt if the RTE is already existing
> when register a GSI, so "rte" will not removed from rte_list when the
> iosapic is removed.

Hi Hanjun,

I think updating rte->refcnt makes sense as long as rte->iosapic points
to a valid iosapic entry.  It looks odd to me that rte->iosapic is left
pointing an invalid iosapic entry after this iosapic is removed.  So, I
agree with Tony's concern.

Thanks,
-Toshi


> Actually, the rte_list will keep static when remove/add a existing iosapic
> after boot up.
> 
> Should we remove the RTE from the rte_list? if yes, we will have more
> to do than this patch.
> 
> Thanks
> Hanjun Guo
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


