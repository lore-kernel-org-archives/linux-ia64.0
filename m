From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 10 Jan 2005 21:54:45 +0000
Subject: Re: [PATCH] fix warning in arch/ia64/pci/pci.c
Message-Id: <200501101354.46000.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501101325.49728.jbarnes@engr.sgi.com>
In-Reply-To: <200501101325.49728.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, January 10, 2005 1:52 pm, Matthew Wilcox wrote:
> On Mon, Jan 10, 2005 at 01:25:49PM -0800, Jesse Barnes wrote:
> > Bjorn, I think you had a similar fix awhile back?
>
> Was me actually ... mine looked like this:
>
> +#ifdef CONFIG_NUMA
> +extern acpi_status acpi_map_iosapic (acpi_handle, u32, void*, void**);
> +#define map_apics() acpi_get_devices(NULL, acpi_map_iosapic, NULL, NULL);
> +#else
> +#define map_apics() do { } while (0);
> +#endif
> +
> [...]
> -#ifdef CONFIG_NUMA
> -extern acpi_status acpi_map_iosapic (acpi_handle, u32, void*, void**);
> -
> -       acpi_get_devices(NULL, acpi_map_iosapic, NULL, NULL);
> -#endif
> +       map_apics();
>
> but yours has probbaly even been compiled, and stuff.

Yeah, but I'm happy with either one, they look equivalent (except yours has 
';' at the end of the #defines).

Thanks,
Jesse
