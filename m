From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 07 Feb 2006 07:38:40 +0000
Subject: RE: [PATCH]: Remove kfree, and fix pcidev_info struct removals
Message-Id: <B05667366EE6204181EABE9C1B1C0EB50997CEB6@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060206185244.12145.74416.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20060206185244.12145.74416.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Prarit Bhargava wrote on Monday, February 06, 2006 11:48 AM
> New patch.
> 
> diff --git a/arch/ia64/sn/kernel/io_init.c
b/arch/ia64/sn/kernel/io_init.c
> index d7e4d79..2e4e56b 100644
> --- a/arch/ia64/sn/kernel/io_init.c
> +++ b/arch/ia64/sn/kernel/io_init.c
> @@ -623,6 +623,8 @@ sn_sysdata_free_start:
>  	list_for_each(list, &sn_sysdata_list) {
>  		element = list_entry(list, struct sysdata_el, entry);
>  		list_del(&element->entry);
> +		list_del(&(((struct pcidev_info *)
> +			     (element->sysdata))->pdi_list));
>  		kfree(element->sysdata);
>  		kfree(element);
>  		goto sn_sysdata_free_start;


Nothing in particular picky about this patch.  However, in
sn_bus_free_sysdata(), the goto that branches outside the
list_for_each loop looks like it needs a real clean up. How
about using list_for_each_entry_safe?

- Ken


Excerpt of function sn_bus_free_sysdata():

void sn_bus_free_sysdata(void)
{
        struct sysdata_el *element;
        struct list_head *list;

sn_sysdata_free_start:
        list_for_each(list, &sn_sysdata_list) {
                element = list_entry(list, struct sysdata_el, entry);
                list_del(&element->entry);
                kfree(element->sysdata);
                kfree(element);
                goto sn_sysdata_free_start;
        }
        return;
}
