From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Date: Thu, 09 Aug 2012 15:41:04 +0000
Subject: Re: [RFC PATCH V6 04/19] memory-hotplug: offline and remove memory when removing the memory device
Message-Id: <CAFEPiEY7gBeLoEJggSjFsF92X1Lw9DzPvEfCxhBx75NKCiL6XQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1343980161-14254-1-git-send-email-wency@cn.fujitsu.com>
	<1343980161-14254-5-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1343980161-14254-5-git-send-email-wency@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

Hi,

> We should offline and remove memory when removing the memory device.
> The memory device can be removed by 2 ways:
> 1. send eject request by SCI
> 2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
>

[snip]

> +
> +static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
> +{
> +       int result;
> +
> +       /*
> +        * Ask the VM to offline this memory range.
> +        * Note: Assume that this function returns zero on success
> +        */
> +       result = acpi_memory_device_remove_memory(mem_device);
> +

here we should check the result of acpi_memory_device_remove_memory()
and not continue if it failed.

>         /* Power-off and eject the device */
>         result = acpi_memory_powerdown_device(mem_device);
>         if (result) {

thanks,

- Vasilis
