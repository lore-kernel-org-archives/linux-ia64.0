From: Neil Horman <nhorman@redhat.com>
Date: Tue, 11 Aug 2009 10:46:06 +0000
Subject: Re: [RFC Patch 2/2] kexec: allow to shrink reserved memory
Message-Id: <20090811104606.GA26587@hmsreliant.think-freely.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090811104144.5154.77871.sendpatchset@localhost.localdomain> <20090811104154.5154.78710.sendpatchset@localhost.localdomain>
In-Reply-To: <20090811104154.5154.78710.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>

On Tue, Aug 11, 2009 at 06:39:32AM -0400, Amerigo Wang wrote:
> 
> This patch implements shrinking the reserved memory for crash kernel,
> if it is more than enough.
> 
> For example, if you have already reserved 128M, now you just want 100M,
> you can do:
> 
> # echo $((100*1024*1024)) > /sys/kernel/kexec_crash_size
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Neil Horman <nhorman@redhat.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: Andi Kleen <andi@firstfloor.org>
> 

Since the reserved area is also used for heap in the new kernel, isn't this
mechanism going to guarantee a non-bootable kernel.  It seems like it shrinks
the reserved area to the size of the image, leaving no additional memory for
heap allocations during the kernels boot.  Or am I missing something?

Neil

> ---
> Index: linux-2.6/include/linux/kexec.h
> =================================> --- linux-2.6.orig/include/linux/kexec.h
> +++ linux-2.6/include/linux/kexec.h
> @@ -158,6 +158,8 @@ unsigned long paddr_vmcoreinfo_note(void
>  
>  extern struct kimage *kexec_image;
>  extern struct kimage *kexec_crash_image;
> +extern struct resource *kexec_res;
> +extern struct resource *kexec_free_res;
>  
>  #ifndef kexec_flush_icache_page
>  #define kexec_flush_icache_page(page)
> @@ -206,6 +208,7 @@ extern size_t vmcoreinfo_max_size;
>  
>  int __init parse_crashkernel(char *cmdline, unsigned long long system_ram,
>  		unsigned long long *crash_size, unsigned long long *crash_base);
> +int shrink_crash_memory(unsigned long start, unsigned long end);
>  
>  #else /* !CONFIG_KEXEC */
>  struct pt_regs;
> Index: linux-2.6/kernel/kexec.c
> =================================> --- linux-2.6.orig/kernel/kexec.c
> +++ linux-2.6/kernel/kexec.c
> @@ -1130,6 +1130,51 @@ void crash_kexec(struct pt_regs *regs)
>  	}
>  }
>  
> +int shrink_crash_memory(unsigned long start, unsigned long end)
> +{
> +	struct page **pages;
> +	int ret = 0;
> +	int  npages, i;
> +	unsigned long addr;
> +	void *vaddr;
> +
> +	if (!mutex_trylock(&kexec_mutex))
> +		return -EBUSY;
> +
> +	if (!kexec_free_res) {
> +		ret = -ENOENT;
> +		goto unlock;
> +	}
> +
> +	start = roundup(start, PAGE_SIZE);
> +	end = roundup(end, PAGE_SIZE) - 1;
> +	npages = (end + 1 - start ) / PAGE_SIZE;
> +
> +	pages = kmalloc(sizeof(struct page *) * npages, GFP_KERNEL);
> +	if (!pages) {
> +		ret = -ENOMEM;
> +		goto unlock;
> +	}
> +	for (i = 0; i < npages; i++) {
> +		addr = start + i * PAGE_SIZE;
> +		pages[i] = virt_to_page(addr);
> +	}
> +
> +	vaddr = vm_map_ram(pages, npages, 0, PAGE_KERNEL);
> +	if (!vaddr) {
> +		ret = -ENOMEM;
> +		goto free;
> +	}
> +	kexec_free_res->end = start - 1;
> +	crashk_res.end = start - 1;
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
> @@ -100,6 +100,32 @@ static ssize_t kexec_crash_loaded_show(s
>  }
>  KERNEL_ATTR_RO(kexec_crash_loaded);
>  
> +static ssize_t kexec_crash_size_show(struct kobject *kobj,
> +				       struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%llu\n", crashk_res.end - crashk_res.start + 1);
> +}
> +static ssize_t kexec_crash_size_store(struct kobject *kobj,
> +				   struct kobj_attribute *attr,
> +				   const char *buf, size_t count)
> +{
> +	unsigned long cnt;
> +	int ret;
> +
> +	if (!kexec_res || !kexec_free_res)
> +		return -ENOENT;
> +	cnt = simple_strtoul(buf, NULL, 10);
> +	if (cnt < kexec_res->end - kexec_res->start + 1)
> +		return -ENOENT;
> +	if (cnt > kexec_free_res->end - kexec_res->start + 1)
> +		return -ENOENT;
> +	cnt -= kexec_res->end - kexec_res->start + 1;
> +	ret = shrink_crash_memory(kexec_free_res->start + cnt,
> +		kexec_free_res->end);
> +	return ret < 0 ? ret : count;
> +}
> +KERNEL_ATTR_RW(kexec_crash_size);
> +
>  static ssize_t vmcoreinfo_show(struct kobject *kobj,
>  			       struct kobj_attribute *attr, char *buf)
>  {
> @@ -147,6 +173,7 @@ static struct attribute * kernel_attrs[]
>  #ifdef CONFIG_KEXEC
>  	&kexec_loaded_attr.attr,
>  	&kexec_crash_loaded_attr.attr,
> +	&kexec_crash_size_attr.attr,
>  	&vmcoreinfo_attr.attr,
>  #endif
>  	NULL
