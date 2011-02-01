From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Date: Tue, 01 Feb 2011 09:29:42 +0000
Subject: Re: [RFC][PATCH] kmsg_dumper for NVRAM
Message-Id: <20110201092942.GD21239@cr0.nay.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5C4C569E8A4B9B42A84A977CF070A35B2C1472ACC8@USINDEVS01.corp.hds.com>
In-Reply-To: <5C4C569E8A4B9B42A84A977CF070A35B2C1472ACC8@USINDEVS01.corp.hds.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Seiji Aguchi <seiji.aguchi@hds.com>
Cc: "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "tony.luck@intel.com" <tony.luck@intel.com>, "fenghua.yu@intel.com" <fenghua.yu@intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "tj@kernel.org" <tj@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "arnd@arndb.de" <arnd@arndb.de>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, "shiyer@redhat.com" <shiyer@redhat.com>, "pjones@redhat.com" <pjones@redhat.com>, Satoru Moriya <satoru.moriya@hds.com>

On Mon, Jan 31, 2011 at 11:21:17AM -0500, Seiji Aguchi wrote:
>Hi,
>
>This prototype patch introduces kmsg_dumper for NVRAM(Non-Volatile RAM).
>

Hi,

This looks like what Tony wanted, pstore.

...

>[Patch Description]
>This patch adds following boot paremeters.
>
> - nvram_kmsg_dump_enable
>   Enable kmsg_dumper for NVRAM with UEFI.
>
> - nvram_kmsg_dump_len
>   Size of kernel messages dumped to NVRAM.
>   default size is 1KB.(because I would like to use efivars for reading them from userspace.)
>   Maximum size is 32KB.
>
>On the next boot, sysfs files are created as follows and through these files we can see 
>the kernel messages stored in NVRAM.
>
>    /sys/firmware/efi/vars/LinuxKmsgDump001-8be4df61-93ca-11d2-aa0d-00e098032b8c/data
>    /sys/firmware/efi/vars/LinuxKmsgDump002-8be4df61-93ca-11d2-aa0d-00e098032b8c/data
>          .
>          . 
>    /sys/firmware/efi/vars/LinuxKmsgDump032-8be4df61-93ca-11d2-aa0d-00e098032b8c/data
>
>　　- Size of each entry is 1KB. 32 entries are created at a maximum.
>　　- "8be4df61-93ca-11d2-aa0d-00e098032b8c" is EFI_GLOBAL_VARIABLE which is defined in
>      UEFI specification.
>

So, 'cat /sys/firmware/efi/vars/LinuxKmsgDump*/data' will show
the whole kernel messages? And in the right order?

Also ,will these data be flushed after the next next boot? If not, how
can they be flushed/deleted?


>
>---
> Documentation/kernel-parameters.txt |    9 +++
> arch/ia64/kernel/efi.c              |    4 +
> arch/x86/platform/efi/efi.c         |  135 +++++++++++++++++++++++++++++++++++
> include/linux/efi.h                 |    4 +
> init/main.c                         |    5 +-
> 5 files changed, 156 insertions(+), 1 deletions(-)


Some comments below.


>+static int __init setup_nvram_kmsg_dump_enable(char *arg)
>+{
>+	nvram_kmsg_dump_enabled = 1;
>+	return 0;
>+}
>+__setup("nvram_kmsg_dump_enable", setup_nvram_kmsg_dump_enable);
>+
>+static int __init setup_nvram_kmsg_dump_len(char *str)
>+{
>+	unsigned size = memparse(str, &str);

You ignored errors here.

>+
>+	if (!efi_enabled) {
>+		printk(KERN_INFO "setup_nvram_kmsg_dump_len: EFI is disabled\n");
>+		return 1;
>+	}
>+
>+	if (size)
>+		size = roundup_pow_of_two(size);
>+	if (size > nvram_kmsg_dump_len) {
>+		char *new_nvram_kmsg_dump;
>+
>+		new_nvram_kmsg_dump = alloc_bootmem(size);
>+		if (!new_nvram_kmsg_dump) {
>+			printk(KERN_WARNING "nvram_kmsg_dump_len: \
>+allocation failed\n");

We don't split strings like this.

>+			return 1;
>+		}
>+		nvram_kmsg_dump_len = size;
>+		nvram_kmsg_dump_buf = new_nvram_kmsg_dump;
>+	}
>+	printk(KERN_NOTICE "nvram_kmsg_dump_len: %d\n", nvram_kmsg_dump_len);
>+
>+	return 0;
>+
>+}
>+__setup("nvram_kmsg_dump_len=", setup_nvram_kmsg_dump_len);
>+
>+static void nvram_do_kmsg_dump(struct kmsg_dumper *dumper,
>+	enum kmsg_dump_reason reason, const char *s1, unsigned long l1,
>+	const char *s2, unsigned long l2)
>+{
>+	unsigned long s1_start, s2_start, l1_cpy, l2_cpy;
>+	unsigned long attribute = 0xf, total, tmp, cpy_size;
>+	int i;
>+	efi_status_t efi_status;
>+	void *tmp_buf;
>+
>+	l2_cpy = min(l2, (unsigned long)nvram_kmsg_dump_len);
>+	l1_cpy = min(l1, (unsigned long)nvram_kmsg_dump_len - l2_cpy);
>+
>+	s2_start = l2 - l2_cpy;
>+	s1_start = l1 - l1_cpy;
>+
>+	memcpy(nvram_kmsg_dump_buf, s1 + s1_start, l1_cpy);
>+	memcpy(nvram_kmsg_dump_buf + l1_cpy, s2 + s2_start, l2_cpy);
>+
>+	/* initialize */
>+	for (i = 0; i < MAX_ENTRY; i++)
>+		efi.set_variable(kmsg_dump_value_utf16[i],
>+				 &EFI_GLOBAL_VARIABLE_GUID,
>+				 attribute, 0, NULL);
>+
>+	/* write data */
>+	total = l1_cpy + l2_cpy;
>+	tmp_buf = (void *)nvram_kmsg_dump_buf + total;
>+	cpy_size = 0;
>+	for (i = 0; i < MAX_ENTRY; i++) {
>+		tmp = min(total - cpy_size, (unsigned long)SET_VARIABLE_LEN);
>+		tmp_buf -= tmp;
>+		efi_status = efi.set_variable(kmsg_dump_value_utf16[i],
>+					      &EFI_GLOBAL_VARIABLE_GUID,
>+					      attribute, tmp, tmp_buf);
>+		if (efi_status) {
>+			printk(KERN_WARNING "nvram_do_kmsg_dump: \
>+set_variable %d failed 0x%lx\n", i, efi_status);

Ditto.

>+			efi.set_variable(kmsg_dump_value_utf16[i],
>+					 &EFI_GLOBAL_VARIABLE_GUID,
>+					 attribute, 0, NULL);
>+			tmp_buf += tmp;
>+			cpy_size -= tmp;
>+		}
>+		cpy_size += tmp;
>+		if (cpy_size >= total)
>+			break;
>+	}
>+}
>+
>+void nvram_kmsg_dump_init(void)
>+{
>+
>+	int i, outlen, err;
>+
>+	for (i = 0; i < MAX_ENTRY; i++) {
>+		snprintf(kmsg_dump_value, sizeof(kmsg_dump_value),
>+			 "%s%04d", LINUX_KMSG_DUMP_PREFIX, i + 1);
>+		outlen = utf8s_to_utf16s((u8 *)kmsg_dump_value,
>+					 sizeof(kmsg_dump_value),
>+					 (wchar_t *)kmsg_dump_value_utf16[i]);
>+		if (outlen != LINUX_KMSG_DUMP_LEN - 1) {
>+			printk(KERN_ERR
>+			       "nvram_kmsg_dump_init: utf8s_to_utf16s %d\n",
>+			       outlen);
>+		return;
>+		}
>+	}
>+
>+	memset(&nvram_kmsg_dumper, 0, sizeof(nvram_kmsg_dumper));


You don't need to memset a static gloabl var to 0.


>+	nvram_kmsg_dumper.dump = nvram_do_kmsg_dump;
>+	err = kmsg_dump_register(&nvram_kmsg_dumper);
>+	if (err) {
>+		printk(KERN_ERR "nvram_kmsg_dump_init: kmsg_dump_register %d\n",
>+		       err);
>+		return;
>+	}
>+	printk(KERN_NOTICE "nvram_kmsg_dump initialized\n");
>+
>+	return;
>+}
>diff --git a/include/linux/efi.h b/include/linux/efi.h
>index fb737bc..d0d1a3c 100644
>--- a/include/linux/efi.h
>+++ b/include/linux/efi.h
>@@ -300,6 +300,7 @@ extern void efi_initialize_iomem_resources(struct resource *code_resource,
> extern unsigned long efi_get_time(void);
> extern int efi_set_rtc_mmss(unsigned long nowtime);
> extern struct efi_memory_map memmap;
>+extern void nvram_kmsg_dump_init(void);
> 
> /**
>  * efi_range_is_wc - check the WC bit on an address range
>@@ -333,11 +334,14 @@ extern int __init efi_setup_pcdp_console(char *);
> #ifdef CONFIG_EFI
> # ifdef CONFIG_X86
>    extern int efi_enabled;
>+   extern int nvram_kmsg_dump_enabled;
> # else
> #  define efi_enabled 1
>+#  define nvram_kmsg_dump_enabled 1


There is a global var with the same name, right?

