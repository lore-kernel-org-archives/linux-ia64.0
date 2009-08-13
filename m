From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 13 Aug 2009 03:11:55 +0000
Subject: Re: [Patch 8/8] kexec: allow to shrink reserved memory
Message-Id: <m1bpmk8l1g.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>
	<20090812081906.5757.39417.sendpatchset@localhost.localdomain>
In-Reply-To: <20090812081906.5757.39417.sendpatchset@localhost.localdomain> (Amerigo Wang's message of "Wed\, 12 Aug 2009 04\:16\:44 -0400")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Amerigo Wang <amwang@redhat.com> writes:

> This patch implements shrinking the reserved memory for crash kernel,
> if it is more than enough.
>
> For example, if you have already reserved 128M, now you just want 100M,
> you can do:
>
> # echo $((100*1024*1024)) > /sys/kernel/kexec_crash_size

Getting closer (comments inline)

Semantically this patch is non-contriversial and pretty
simple, but still needs a fair amount of review.  Can
you put this patch at the front of your patch set.

> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Neil Horman <nhorman@redhat.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: Andi Kleen <andi@firstfloor.org>
>
> ---
>
> Index: linux-2.6/include/linux/kexec.h
> =================================> --- linux-2.6.orig/include/linux/kexec.h
> +++ linux-2.6/include/linux/kexec.h
> @@ -206,6 +206,9 @@ extern size_t vmcoreinfo_max_size;
>  
>  int __init parse_crashkernel(char *cmdline, unsigned long long system_ram,
>  		unsigned long long *crash_size, unsigned long long *crash_base);
> +int shrink_crash_memory(unsigned long new_size);
> +int kexec_crash_kernel_loaded(void);
> +size_t get_crash_memory_size(void);
>  
>  #else /* !CONFIG_KEXEC */
>  struct pt_regs;
> Index: linux-2.6/kernel/kexec.c
> =================================> --- linux-2.6.orig/kernel/kexec.c
> +++ linux-2.6/kernel/kexec.c
> @@ -1083,6 +1083,76 @@ void crash_kexec(struct pt_regs *regs)
>  	}
>  }
>  
> +int kexec_crash_kernel_loaded(void)
> +{
> +	int ret;
> +	if (!mutex_trylock(&kexec_mutex))
> +		return 1;

We don't need trylock on this code path 

> +	ret = kexec_crash_image != NULL;
> +	mutex_unlock(&kexec_mutex);
> +	return ret;
> +}
> +
> +size_t get_crash_memory_size(void)
> +{
> +	size_t size;
> +	if (!mutex_trylock(&kexec_mutex))
> +		return 1;

We don't need trylock on this code path 

> +	size = crashk_res.end - crashk_res.start + 1;
> +	mutex_unlock(&kexec_mutex);
> +	return size;
> +}
> +
> +int shrink_crash_memory(unsigned long new_size)
> +{
> +	struct page **pages;
> +	int ret = 0;
> +	int  npages, i;
> +	unsigned long addr;
> +	unsigned long start, end;
> +	void *vaddr;
> +
> +	if (!mutex_trylock(&kexec_mutex))
> +		return -EBUSY;

We don't need trylock on this code path 

We are missing the check to see if the crash_kernel is loaded
under this lock instance. So I please move the kexec_crash_image != NULL
test inline here and kill the kexec_crash_kernel_loaded function.

> +	start = crashk_res.start;
> +	end = crashk_res.end;
> +
> +	if (new_size >= end - start + 1) {
> +		ret = -EINVAL;
> +		if (new_size = end - start + 1)
> +			ret = 0;
> +		goto unlock;
> +	}
> +
> +	start = roundup(start, PAGE_SIZE);
> +	end = roundup(start + new_size, PAGE_SIZE) - 1;
> +	npages = (end + 1 - start ) / PAGE_SIZE;
> +
> +	pages = kmalloc(sizeof(struct page *) * npages, GFP_KERNEL);
> +	if (!pages) {
> +		ret = -ENOMEM;
> +		goto unlock;
> +	}
> +	for (i = 0; i < npages; i++) {
> +		addr = end + 1 + i * PAGE_SIZE;
> +		pages[i] = virt_to_page(addr);
> +	}
> +
> +	vaddr = vm_map_ram(pages, npages, 0, PAGE_KERNEL);

This is the wrong kernel call to use.  I expect this needs to look
like a memory hotplug event.  This does not put the pages into the
free page pool.

> +	if (!vaddr) {
> +		ret = -ENOMEM;
> +		goto free;
> +	}
> +	crashk_res.end = end;
> +
> +free:
> +	kfree(pages);
> +unlock:
> +	mutex_unlock(&kexec_mutex);
> +	return ret;
> +}
> +
>  static u32 *append_elf_note(u32 *buf, char *name, unsigned type, void *data,
>  			    size_t data_len)
>  {
> Index: linux-2.6/kernel/ksysfs.c
> =================================> --- linux-2.6.orig/kernel/ksysfs.c
> +++ linux-2.6/kernel/ksysfs.c
> @@ -100,6 +100,26 @@ static ssize_t kexec_crash_loaded_show(s
>  }
>  KERNEL_ATTR_RO(kexec_crash_loaded);
>  
> +static ssize_t kexec_crash_size_show(struct kobject *kobj,
> +				       struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%lu\n", get_crash_memory_size());
> +}
> +static ssize_t kexec_crash_size_store(struct kobject *kobj,
> +				   struct kobj_attribute *attr,
> +				   const char *buf, size_t count)
> +{
> +	unsigned long cnt;
> +	int ret;
> +
> +	if (kexec_crash_kernel_loaded())
> +		return -ENOENT;
> +	cnt = simple_strtoul(buf, NULL, 10);
> +	ret = shrink_crash_memory(cnt);
> +	return ret < 0 ? ret: count;
> +}
> +KERNEL_ATTR_RW(kexec_crash_size);
> +
>  static ssize_t vmcoreinfo_show(struct kobject *kobj,
>  			       struct kobj_attribute *attr, char *buf)
>  {
> @@ -147,6 +167,7 @@ static struct attribute * kernel_attrs[]
>  #ifdef CONFIG_KEXEC
>  	&kexec_loaded_attr.attr,
>  	&kexec_crash_loaded_attr.attr,
> +	&kexec_crash_size_attr.attr,
>  	&vmcoreinfo_attr.attr,
>  #endif
>  	NULL
