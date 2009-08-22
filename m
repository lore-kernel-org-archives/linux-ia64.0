From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 22 Aug 2009 01:39:43 +0000
Subject: Re: [Patch 1/8] kexec: allow to shrink reserved memory
Message-Id: <m18whcr5i8.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090821065637.4855.32234.sendpatchset@localhost.localdomain>
	<20090821065650.4855.53279.sendpatchset@localhost.localdomain>
In-Reply-To: <20090821065650.4855.53279.sendpatchset@localhost.localdomain> (Amerigo Wang's message of "Fri\, 21 Aug 2009 02\:54\:25 -0400")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, kamezawa.hiroyu@jp.fujitsu.com, Anton Vorontsov <avorontsov@ru.mvista.com>

Amerigo Wang <amwang@redhat.com> writes:

> This patch implements shrinking the reserved memory for crash kernel,
> if it is more than enough.
>
> For example, if you have already reserved 128M, now you just want 100M,
> you can do:
>
> # echo $((100*1024*1024)) > /sys/kernel/kexec_crash_size
>
> Note, you can only do this before loading the crash kernel.
>
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Neil Horman <nhorman@redhat.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: Andi Kleen <andi@firstfloor.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> ---
>
> Index: linux-2.6/include/linux/kexec.h
> =================================> --- linux-2.6.orig/include/linux/kexec.h
> +++ linux-2.6/include/linux/kexec.h
> @@ -206,6 +206,8 @@ extern size_t vmcoreinfo_max_size;
>  
>  int __init parse_crashkernel(char *cmdline, unsigned long long system_ram,
>  		unsigned long long *crash_size, unsigned long long *crash_base);
> +int shrink_crash_memory(unsigned long new_size);
> +size_t get_crash_memory_size(void);
>  
>  #else /* !CONFIG_KEXEC */
>  struct pt_regs;
> Index: linux-2.6/kernel/kexec.c
> =================================> --- linux-2.6.orig/kernel/kexec.c
> +++ linux-2.6/kernel/kexec.c
> @@ -31,6 +31,7 @@
>  #include <linux/cpu.h>
>  #include <linux/console.h>
>  #include <linux/vmalloc.h>
> +#include <linux/swap.h>
>  
>  #include <asm/page.h>
>  #include <asm/uaccess.h>
> @@ -1083,6 +1084,58 @@ void crash_kexec(struct pt_regs *regs)
>  	}
>  }
>  
> +size_t get_crash_memory_size(void)
> +{
> +	size_t size;
> +	mutex_lock(&kexec_mutex);
> +	size = crashk_res.end - crashk_res.start + 1;
> +	mutex_unlock(&kexec_mutex);
> +	return size;
> +}
> +
> +int shrink_crash_memory(unsigned long new_size)
> +{
> +	int ret = 0;
> +	unsigned long addr;
> +	unsigned long start, end;
> +
> +	mutex_lock(&kexec_mutex);
> +
> +	if (kexec_crash_image) {
> +		ret = -ENOENT;
> +		goto unlock;
> +	}
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
> +	end = roundup(start + new_size, PAGE_SIZE);
> +
> +	for (addr = end; addr < crashk_res.end; addr += PAGE_SIZE) {
> +		ClearPageReserved(pfn_to_page(addr >> PAGE_SHIFT));
> +		init_page_count(pfn_to_page(addr >> PAGE_SHIFT));
> +		free_page((unsigned long)__va(addr));
> +		totalram_pages++;

Any chance we can move this inline snippet into a helper function in
-mm.  To expose what is happening here to the mm developers.

Eric

> +	}
> +
> +	if (start = end) {
> +		crashk_res.end = end;
> +		release_resource(&crashk_res);
> +	} else
> +		crashk_res.end = end - 1;
> +
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
> +	if (strict_strtoul(buf, 0, &cnt))
> +		return -EINVAL;
> +
> +	ret = shrink_crash_memory(cnt);
> +	return ret < 0 ? ret : count;
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
