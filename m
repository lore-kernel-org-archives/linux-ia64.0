From: Ni zhan Chen <nizhan.chen@gmail.com>
Date: Fri, 28 Sep 2012 03:21:37 +0000
Subject: Re: [RFC v9 PATCH 03/21] memory-hotplug: store the node id in acpi_memory_device
Message-Id: <506517C1.7050909@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com> <1346837155-534-4-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1346837155-534-4-git-send-email-wency@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wency@cn.fujitsu.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

On 09/05/2012 05:25 PM, wency@cn.fujitsu.com wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
>
> The memory device has only one node id. Store the node id when
> enable the memory device, and we can reuse it when removing the
> memory device.

one question:
if use numa emulation, memory device will associated to one node or ...?

>
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> CC: Len Brown <len.brown@intel.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org>
> CC: Christoph Lameter <cl@linux.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> ---
>   drivers/acpi/acpi_memhotplug.c |    4 ++++
>   1 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index 2a7beac..7873832 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -83,6 +83,7 @@ struct acpi_memory_info {
>   struct acpi_memory_device {
>   	struct acpi_device * device;
>   	unsigned int state;	/* State of the memory device */
> +	int nid;
>   	struct list_head res_list;
>   };
>   
> @@ -256,6 +257,9 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>   		info->enabled = 1;
>   		num_enabled++;
>   	}
> +
> +	mem_device->nid = node;
> +
>   	if (!num_enabled) {
>   		printk(KERN_ERR PREFIX "add_memory failed\n");
>   		mem_device->state = MEMORY_INVALID_STATE;

