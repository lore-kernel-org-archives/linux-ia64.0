From: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Date: Mon, 27 Sep 2004 12:50:27 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[3/6]-Mapping lsapic to cpu
Message-Id: <20040927215027.52fd48b7.tokunaga.keiich@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com>
 <20040920093819.E14208@unix-os.sc.intel.com>
 <20040922221538.650986f2.tokunaga.keiich@jp.fujitsu.com>
 <1095864779.6105.3.camel@tdi>
 <20040923021031.00007001.tokunaga.keiich@jp.fujitsu.com>
 <20040924163632.C27778@unix-os.sc.intel.com>
In-Reply-To: <20040924163632.C27778@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Cc: tokunaga.keiich@jp.fujitsu.com, alex.williamson@hp.com, len.brown@intel.com, acpi-devel@lists.sourceforge.net, lhns-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 24 Sep 2004 16:36:32 -0700 Keshavamurthy Anil S wrote:
> On Thu, Sep 23, 2004 at 02:10:31AM +0900, Keiichiro Tokunaga wrote:
> > On Wed, 22 Sep 2004 08:52:59 -0600, Alex Williamson wrote:
> > > On Wed, 2004-09-22 at 22:15 +0900, Keiichiro Tokunaga wrote:
> > > > 
> > > > I would like to suggest introducing a new function 'acpi_get_pxm()'
> > > > since other drivers might need it in the future.  Acutally, ACPI container
> > > > hotplug will be using it soon.
> > > > 
> > > > Here is a patch creating the function.
> > > > 
> > > 
> > >    Nice, I have a couple I/O locality patches that could be simplified
> 
> Here is the revised patch which now fixes the all issues that were discussed.
> 	- Now defines and uses acpi_get_pxm
> 	- small bugfix "change __initdata to __devinitdata for pxm_to_nid_map varable

One more thing.  Did you modify my acpi_get_pxm.patch by hand?
That causes an infinite loop.  Please apply my fix patch.

> +int
> +acpi_get_pxm(acpi_handle handle)
> +{
> +	unsigned long pxm;
> +	acpi_status status;
> +	acpi_handle phandle;
> +
> +	do {
> +		status = acpi_evaluate_integer(handle, "_PXM", NULL, &pxm);
> +		if (ACPI_SUCCESS(status))
> +			return (int)pxm;
> +		status = acpi_get_parent(handle, &phandle);
> +	} while(ACPI_SUCCESS(status));
> +	return -1;
> +}
> +EXPORT_SYMBOL(acpi_get_pxm);
> _

This do-loop never ends...

Thanks,
Keiichiro Tokunaga

Status: Tested on 2.6.9-rc2
Signed-off-by: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
---

 linux-2.6.9-rc2-092704-kei/drivers/acpi/numa.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff -puN drivers/acpi/numa.c~acpi_get_pxm-fix drivers/acpi/numa.c
--- linux-2.6.9-rc2-092704/drivers/acpi/numa.c~acpi_get_pxm-fix	2004-09-27 20:44:22.000000000 +0900
+++ linux-2.6.9-rc2-092704-kei/drivers/acpi/numa.c	2004-09-27 21:33:24.266377945 +0900
@@ -198,13 +198,15 @@ acpi_numa_init()
 }
 
 int
-acpi_get_pxm(acpi_handle handle)
+acpi_get_pxm(acpi_handle h)
 {
 	unsigned long pxm;
 	acpi_status status;
-	acpi_handle phandle;
+	acpi_handle handle;
+	acpi_handle phandle = h;
 
 	do {
+		handle = phandle;
 		status = acpi_evaluate_integer(handle, "_PXM", NULL, &pxm);
 		if (ACPI_SUCCESS(status))
 			return (int)pxm;

_
