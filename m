From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 12 Sep 2005 03:29:22 +0000
Subject: Re: [RFC] /proc/efi_memmap
Message-Id: <4324F612.8020903@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509092346.j89NkDdo001318@agluck-lia64.sc.intel.com>
In-Reply-To: <200509092346.j89NkDdo001318@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> kexec folks asked whether I could export the EFI memory map in /proc
> for use by their user level tools.
> 
What does Kexec-people really want ?
Excact EFI memory map ? or physical address map with some attributes ?

(exporiting just EFI memmap looks easy but...)
I think EFI memory map cannot cooperate with memory hotplug and
will be obsolete in future.
So more generic "physical memory map" looks good.

 > 1) Is /proc/efi_memmap a good name?
just rename to memory_map and show efi's for now looks good.

 > +	seq_printf(m, "%4d %16.16lx %16.16lx %lx\n", md->type, md->phys_addr,
 > +		efi_md_end(md), md->attribute);

and please define more "generic format".
If an interface is fixed, we can change implementation.


BTW, EFI memory map doesn't matches kernel's memory view (by GRANULE etc..)
It isn't problem for kexec-people ?

-- Kame <kamezawa.hiroyu@jp.fujitsu.com>

> Questions:
> 0) Is this information already available some place I missed?
> 1) Is /proc/efi_memmap a good name?
> 2) I used mm/slab.c as my model for using seq_file ... does this look right?
> 
> -Tony
> 
> Patch against the "test" branch of my GIT tree.
> 
> ---
> 
> diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
> --- a/arch/ia64/kernel/efi.c
> +++ b/arch/ia64/kernel/efi.c
> @@ -22,6 +22,8 @@
>  #include <linux/module.h>
>  #include <linux/kernel.h>
>  #include <linux/init.h>
> +#include <linux/proc_fs.h>
> +#include <linux/seq_file.h>
>  #include <linux/types.h>
>  #include <linux/time.h>
>  #include <linux/efi.h>
> @@ -923,3 +925,89 @@ efi_memmap_init(unsigned long *s, unsign
>  	*s = (u64)kern_memmap;
>  	*e = (u64)++k;
>  }
> +
> +#ifdef CONFIG_PROC_FS
> +
> +static void *s_start(struct seq_file *m, loff_t *pos)
> +{
> +	loff_t n = *pos;
> +	void *efi_map_start, *efi_map_end, *p;
> +	u64	efi_desc_size;
> +
> +	if (!n)
> +		seq_puts(m, "type            start              end attributes\n");
> +
> +	p = efi_map_start = __va(ia64_boot_param->efi_memmap);
> +	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
> +	efi_desc_size = ia64_boot_param->efi_memdesc_size;
> +
> +	while (n--) {
> +		p += efi_desc_size;
> +		if (p >= efi_map_end)
> +			return NULL;
> +	}
> +
> +	return p;
> +}
> +
> +static void *s_next(struct seq_file *m, void *p, loff_t *pos)
> +{
> +	void *efi_map_start, *efi_map_end;
> +	u64	efi_desc_size;
> +
> +	++*pos;
> +
> +	efi_map_start = __va(ia64_boot_param->efi_memmap);
> +	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
> +	efi_desc_size = ia64_boot_param->efi_memdesc_size;
> +
> +	return (p + efi_desc_size >= efi_map_end) ? NULL : p + efi_desc_size;
> +}
> +
> +static void s_stop(struct seq_file *m, void *p)
> +{
> +}
> +
> +static int s_show(struct seq_file *m, void *p)
> +{
> +	efi_memory_desc_t *md = p;
> +
> +	seq_printf(m, "%4d %16.16lx %16.16lx %lx\n", md->type, md->phys_addr,
> +		efi_md_end(md), md->attribute);
> +
> +	return 0;
> +}
> +
> +static struct seq_operations efimeminfo_op = {
> +	.start	= s_start,
> +	.next	= s_next,
> +	.stop	= s_stop,
> +	.show	= s_show,
> +};
> +
> +static int efimeminfo_open(struct inode *inode, struct file *file)
> +{
> +        return seq_open(file, &efimeminfo_op);
> +}
> +
> +static struct file_operations proc_efimeminfo_operations = {
> +	.open		= efimeminfo_open,
> +	.read		= seq_read,
> +	.llseek		= seq_lseek,
> +	.release	= seq_release,
> +};
> +
> +static int __init
> +efi_procmem(void)
> +{
> +	struct proc_dir_entry *entry;
> +
> +	entry = create_proc_entry("efi_memmap", S_IRUGO, NULL);
> +	if (entry)
> +		entry->proc_fops = &proc_efimeminfo_operations;
> +
> +	return 0;
> +}
> +late_initcall(efi_procmem);
> +
> +#endif
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


