From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Date: Thu, 23 Sep 2004 22:09:13 +0000
Subject: Re: [PATCH][4/4] Add NUMA node handling to the container driver
Message-Id: <41534989.3070001@kolumbus.fi>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com>	<20040920094719.H14208@unix-os.sc.intel.com>	<20040924012301.000007c6.tokunaga.keiich@jp.fujitsu.com> <20040924013642.00003b08.tokunaga.keiich@jp.fujitsu.com>
In-Reply-To: <20040924013642.00003b08.tokunaga.keiich-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keiichiro Tokunaga <tokunaga.keiich-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: anil.s.keshavamurthy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, lhns-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Keiichiro Tokunaga wrote:

>Name: container_for_numa.patch
>Status: Tested on 2.6.9-rc2
>Signed-off-by: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
>Description:
>Add NUMA node handling to the container driver.
>
>Thanks,
>Keiichiro Tokunaga
>---
>  
>

>@@ -198,6 +208,7 @@ container_device_add(struct acpi_device 
> 	if (acpi_bus_add(device, pdev, handle, ACPI_BUS_TYPE_DEVICE)) {
> 		return_VALUE(-ENODEV);
> 	}
>+	container_numa_add((*device)->handle);
>  
>
Maybe that should be :

container_numa_add(phandle);
 
instead? Device is the child at this point.

--Mika



