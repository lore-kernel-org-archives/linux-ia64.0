From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 10 Jan 2005 21:52:35 +0000
Subject: Re: [PATCH] fix warning in arch/ia64/pci/pci.c
Message-Id: <20050110215235.GR27371@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501101325.49728.jbarnes@engr.sgi.com>
In-Reply-To: <200501101325.49728.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jan 10, 2005 at 01:25:49PM -0800, Jesse Barnes wrote:
> Bjorn, I think you had a similar fix awhile back?

Was me actually ... mine looked like this:

+#ifdef CONFIG_NUMA
+extern acpi_status acpi_map_iosapic (acpi_handle, u32, void*, void**);
+#define map_apics() acpi_get_devices(NULL, acpi_map_iosapic, NULL, NULL);
+#else
+#define map_apics() do { } while (0);
+#endif
+
[...]
-#ifdef CONFIG_NUMA
-extern acpi_status acpi_map_iosapic (acpi_handle, u32, void*, void**);
-
-       acpi_get_devices(NULL, acpi_map_iosapic, NULL, NULL);
-#endif
+       map_apics();

but yours has probbaly even been compiled, and stuff.

> Fix a 'mixing code and declarations' warning in pci.c by creating a small 
> function that's a no-op if CONFIG_NUMA=n but otherwise includes the proper 
> extern.
> 
> Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
> 
> Thanks,
> Jesse

> === arch/ia64/pci/pci.c 1.60 vs edited ==> --- 1.60/arch/ia64/pci/pci.c	2005-01-04 18:48:18 -08:00
> +++ edited/arch/ia64/pci/pci.c	2005-01-06 17:49:11 -08:00
> @@ -131,6 +131,19 @@
>  	.write = pci_write,
>  };
>  
> +#ifdef CONFIG_NUMA
> +extern acpi_status acpi_map_iosapic(acpi_handle, u32, void *, void **);
> +static void acpi_map_iosapics(void)
> +{
> +	acpi_get_devices(NULL, acpi_map_iosapic, NULL, NULL);
> +}
> +#else
> +static void acpi_map_iosapics(void)
> +{
> +	return;
> +}
> +#endif /* CONFIG_NUMA */
> +
>  static int __init
>  pci_acpi_init (void)
>  {
> @@ -138,11 +151,7 @@
>  
>  	printk(KERN_INFO "PCI: Using ACPI for IRQ routing\n");
>  
> -#ifdef CONFIG_NUMA
> -extern acpi_status acpi_map_iosapic (acpi_handle, u32, void*, void**);
> -
> -	acpi_get_devices(NULL, acpi_map_iosapic, NULL, NULL);
> -#endif
> +	acpi_map_iosapics();
>  
>  	if (pci_routeirq) {
>  		/*


-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
