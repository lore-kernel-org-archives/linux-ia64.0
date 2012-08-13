From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 13 Aug 2012 02:54:09 +0000
Subject: RE: [BUGFIX PATCH][RESEND] kexec & iosapic: kexec oops when iosapic was removed
Message-Id: <3908561D78D1C84285E8C5FCA982C28F19375F30@ORSMSX104.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1344583395-9128-1-git-send-email-guohanjun@huawei.com>
 <5025CD41.2030502@huawei.com>
In-Reply-To: <5025CD41.2030502@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hanjun Guo <guohanjun@huawei.com>, "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Eric Biederman <ebiederm@xmission.com>, Vivek Goyal <vgoyal@redhat.com>, Haren Myneni <hbabu@us.ibm.com>, Toshi Kani <toshi.kani@hp.com>, Yinghai Lu <yinghai@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>

>		vec = irq_to_vector(irq);
> 		list_for_each_entry(rte, &info->rtes,
> 				rte_list) {
> +			if (rte->refcnt = NO_REF_RTE)
> +				continue;
> +
> 			iosapic_write(rte->iosapic,
> 					IOSAPIC_RTE_LOW(rte->rte_index),
> 					IOSAPIC_MASK|vec);

This will work - but is it papering over a problem when you removed the
iosapic? Should we really have removed this "rte" from rte_list when the
iosapic was removed?

-Tony

.




