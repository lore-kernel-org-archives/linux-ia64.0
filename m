From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 17 Feb 2014 06:57:30 +0000
Subject: Re: [PATCH] IA64, sba_iommu: fix section mismatch
Message-Id: <5301B2DA.2030101@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1392616684-8410-1-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1392616684-8410-1-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> -static int __init
> +static int
>  acpi_sba_ioc_add(struct acpi_device *device,
>  		 const struct acpi_device_id *not_used)
>  {
> 

Hi Gerry,
   ioc_init() and sba_map_ioc_to_node() in this function seems also have the __init annotate.


-- 
Thanks!
Yijing

