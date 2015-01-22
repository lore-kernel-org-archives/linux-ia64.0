From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Thu, 22 Jan 2015 22:43:16 +0000
Subject: Re: [RFC PATCH] ACPI: Introduce acpi_unload_parent_table() usages in Linux kernel.
Message-Id: <8541914.sW9yU28g98@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <1418746353-3481-2-git-send-email-octavian.purdila@intel.com> <0d37f4eecdd2c7e3203fca7adb1c2c03a16a40dd.1421907258.git.lv.zheng@intel.com>
In-Reply-To: <0d37f4eecdd2c7e3203fca7adb1c2c03a16a40dd.1421907258.git.lv.zheng@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lv Zheng <lv.zheng@intel.com>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Len Brown <len.brown@intel.com>, Lv Zheng <zetalog@gmail.com>, linux-acpi@vger.kernel.org, Octavian Purdila <octavian.purdila@intel.com>, Prarit Bhargava <prarit@sgi.com>, Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Thursday, January 22, 2015 02:37:49 PM Lv Zheng wrote:
> ACPICA has implemented acpi_unload_parent_table() which can exactly replace
> the acpi_get_id()/acpi_unload_table_id() implemented in Linux kernel.  The
> acpi_unload_parent_table() has been unit tested in ACPICA simulation
> environment.
> 
> This patch can also help to reduce the source code differences between
> Linux and ACPICA.

Looks OK to me.

Do you want me to pick it up?

> Signed-off-by: Lv Zheng <lv.zheng@intel.com>
> Cc: Octavian Purdila <octavian.purdila@intel.com>
> Cc: Prarit Bhargava <prarit@sgi.com>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> Cc: linux-pci@vger.kernel.org
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> ---
>  drivers/acpi/acpica/nsxfobj.c     |   44 -------------------------------------
>  drivers/acpi/acpica/tbxface.c     |   39 --------------------------------
>  drivers/pci/hotplug/sgi_hotplug.c |   13 ++++++-----
>  include/acpi/acpixf.h             |    6 -----
>  4 files changed, 7 insertions(+), 95 deletions(-)
> 
> diff --git a/drivers/acpi/acpica/nsxfobj.c b/drivers/acpi/acpica/nsxfobj.c
> index dae9401..51a8329 100644
> --- a/drivers/acpi/acpica/nsxfobj.c
> +++ b/drivers/acpi/acpica/nsxfobj.c
> @@ -53,50 +53,6 @@ ACPI_MODULE_NAME("nsxfobj")
>  
>  /*******************************************************************************
>   *
> - * FUNCTION:    acpi_get_id
> - *
> - * PARAMETERS:  Handle          - Handle of object whose id is desired
> - *              ret_id          - Where the id will be placed
> - *
> - * RETURN:      Status
> - *
> - * DESCRIPTION: This routine returns the owner id associated with a handle
> - *
> - ******************************************************************************/
> -acpi_status acpi_get_id(acpi_handle handle, acpi_owner_id * ret_id)
> -{
> -	struct acpi_namespace_node *node;
> -	acpi_status status;
> -
> -	/* Parameter Validation */
> -
> -	if (!ret_id) {
> -		return (AE_BAD_PARAMETER);
> -	}
> -
> -	status = acpi_ut_acquire_mutex(ACPI_MTX_NAMESPACE);
> -	if (ACPI_FAILURE(status)) {
> -		return (status);
> -	}
> -
> -	/* Convert and validate the handle */
> -
> -	node = acpi_ns_validate_handle(handle);
> -	if (!node) {
> -		(void)acpi_ut_release_mutex(ACPI_MTX_NAMESPACE);
> -		return (AE_BAD_PARAMETER);
> -	}
> -
> -	*ret_id = node->owner_id;
> -
> -	status = acpi_ut_release_mutex(ACPI_MTX_NAMESPACE);
> -	return (status);
> -}
> -
> -ACPI_EXPORT_SYMBOL(acpi_get_id)
> -
> -/*******************************************************************************
> - *
>   * FUNCTION:    acpi_get_type
>   *
>   * PARAMETERS:  handle          - Handle of object whose type is desired
> diff --git a/drivers/acpi/acpica/tbxface.c b/drivers/acpi/acpica/tbxface.c
> index 6482b0d..0f9dd80 100644
> --- a/drivers/acpi/acpica/tbxface.c
> +++ b/drivers/acpi/acpica/tbxface.c
> @@ -265,45 +265,6 @@ ACPI_EXPORT_SYMBOL(acpi_get_table_header)
>  
>  /*******************************************************************************
>   *
> - * FUNCTION:    acpi_unload_table_id
> - *
> - * PARAMETERS:  id            - Owner ID of the table to be removed.
> - *
> - * RETURN:      Status
> - *
> - * DESCRIPTION: This routine is used to force the unload of a table (by id)
> - *
> - ******************************************************************************/
> -acpi_status acpi_unload_table_id(acpi_owner_id id)
> -{
> -	int i;
> -	acpi_status status = AE_NOT_EXIST;
> -
> -	ACPI_FUNCTION_TRACE(acpi_unload_table_id);
> -
> -	/* Find table in the global table list */
> -	for (i = 0; i < acpi_gbl_root_table_list.current_table_count; ++i) {
> -		if (id != acpi_gbl_root_table_list.tables[i].owner_id) {
> -			continue;
> -		}
> -		/*
> -		 * Delete all namespace objects owned by this table. Note that these
> -		 * objects can appear anywhere in the namespace by virtue of the AML
> -		 * "Scope" operator. Thus, we need to track ownership by an ID, not
> -		 * simply a position within the hierarchy
> -		 */
> -		acpi_tb_delete_namespace_by_owner(i);
> -		status = acpi_tb_release_owner_id(i);
> -		acpi_tb_set_table_loaded_flag(i, FALSE);
> -		break;
> -	}
> -	return_ACPI_STATUS(status);
> -}
> -
> -ACPI_EXPORT_SYMBOL(acpi_unload_table_id)
> -
> -/*******************************************************************************
> - *
>   * FUNCTION:    acpi_get_table_with_size
>   *
>   * PARAMETERS:  signature           - ACPI signature of needed table
> diff --git a/drivers/pci/hotplug/sgi_hotplug.c b/drivers/pci/hotplug/sgi_hotplug.c
> index bada2099..c32fb78 100644
> --- a/drivers/pci/hotplug/sgi_hotplug.c
> +++ b/drivers/pci/hotplug/sgi_hotplug.c
> @@ -475,7 +475,7 @@ static int disable_slot(struct hotplug_slot *bss_hotplug_slot)
>  	struct slot *slot = bss_hotplug_slot->private;
>  	struct pci_dev *dev, *temp;
>  	int rc;
> -	acpi_owner_id ssdt_id = 0;
> +	acpi_handle ssdt_hdl = NULL;
>  
>  	/* Acquire update access to the bus */
>  	mutex_lock(&sn_hotplug_mutex);
> @@ -522,7 +522,7 @@ static int disable_slot(struct hotplug_slot *bss_hotplug_slot)
>  			if (ACPI_SUCCESS(ret) &&
>  			    (adr>>16) = (slot->device_num + 1)) {
>  				/* retain the owner id */
> -				acpi_get_id(chandle, &ssdt_id);
> +				ssdt_hdl = chandle;
>  
>  				ret = acpi_bus_get_device(chandle,
>  							  &device);
> @@ -547,12 +547,13 @@ static int disable_slot(struct hotplug_slot *bss_hotplug_slot)
>  	pci_unlock_rescan_remove();
>  
>  	/* Remove the SSDT for the slot from the ACPI namespace */
> -	if (SN_ACPI_BASE_SUPPORT() && ssdt_id) {
> +	if (SN_ACPI_BASE_SUPPORT() && ssdt_hdl) {
>  		acpi_status ret;
> -		ret = acpi_unload_table_id(ssdt_id);
> +		ret = acpi_unload_parent_table(ssdt_hdl);
>  		if (ACPI_FAILURE(ret)) {
> -			printk(KERN_ERR "%s: acpi_unload_table_id failed (0x%x) for id %d\n",
> -			       __func__, ret, ssdt_id);
> +			acpi_handle_err(ssdt_hdl,
> +					"%s: acpi_unload_parent_table failed (0x%x)\n",
> +					__func__, ret);
>  			/* try to continue on */
>  		}
>  	}
> diff --git a/include/acpi/acpixf.h b/include/acpi/acpixf.h
> index 5ba7846..5dd21bc 100644
> --- a/include/acpi/acpixf.h
> +++ b/include/acpi/acpixf.h
> @@ -891,12 +891,6 @@ ACPI_APP_DEPENDENT_RETURN_VOID(ACPI_PRINTF_LIKE(1)
>  ACPI_GLOBAL(u8, acpi_gbl_permanent_mmap);
>  
>  ACPI_EXTERNAL_RETURN_STATUS(acpi_status
> -			    acpi_get_id(acpi_handle object,
> -					acpi_owner_id * out_type))
> -
> -ACPI_EXTERNAL_RETURN_STATUS(acpi_status acpi_unload_table_id(acpi_owner_id id))
> -
> -ACPI_EXTERNAL_RETURN_STATUS(acpi_status
>  			    acpi_get_table_with_size(acpi_string signature,
>  						     u32 instance,
>  						     struct acpi_table_header
> 

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
