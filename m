From: Seiji Aguchi <seiji.aguchi@hds.com>
Date: Mon, 31 Jan 2011 16:21:17 +0000
Subject: [RFC][PATCH] kmsg_dumper for NVRAM
Message-Id: <5C4C569E8A4B9B42A84A977CF070A35B2C1472ACC8@USINDEVS01.corp.hds.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "tony.luck@intel.com" <tony.luck@intel.com>, "fenghua.yu@intel.com" <fenghua.yu@intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "tj@kernel.org" <tj@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "arnd@arndb.de" <arnd@arndb.de>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, "shiyer@redhat.com" <shiyer@redhat.com>, "pjones@redhat.com" <pjones@redhat.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>

Hi,

This prototype patch introduces kmsg_dumper for NVRAM(Non-Volatile RAM).

[Purpose]
My purpose is developing reliable logging feature for enterprise use.
I plan to realize it by using NVRAM equipped with some enterprise servers.

[Solution]
There are following enterprise servers equipped with NVRAM.
 1. Supporting UEFI
 2. Not supporting UEFI

At first, I suggest kmsg_dumper with UEFI because customers will have advan=
tage as follows.

 - UEFI is tolerant of memory corruption because kernel can't access to UEF=
I area.
   In other words, Kernel messages are gotten reliably.

 - Kernel messages are gotten at a very early stage of boot process.
   So we can investigate root cause of a problem even if kdump isn't enable=
d.

[Patch Description]
This patch adds following boot paremeters.

 - nvram_kmsg_dump_enable
   Enable kmsg_dumper for NVRAM with UEFI.

 - nvram_kmsg_dump_len
   Size of kernel messages dumped to NVRAM.
   default size is 1KB.(because I would like to use efivars for reading the=
m from userspace.)
   Maximum size is 32KB.

On the next boot, sysfs files are created as follows and through these file=
s we can see=20
the kernel messages stored in NVRAM.

    /sys/firmware/efi/vars/LinuxKmsgDump001-8be4df61-93ca-11d2-aa0d-00e0980=
32b8c/data
    /sys/firmware/efi/vars/LinuxKmsgDump002-8be4df61-93ca-11d2-aa0d-00e0980=
32b8c/data
          .
          .=20
    /sys/firmware/efi/vars/LinuxKmsgDump032-8be4df61-93ca-11d2-aa0d-00e0980=
32b8c/data

=E3=80=80=E3=80=80- Size of each entry is 1KB. 32 entries are created at a =
maximum.
=E3=80=80=E3=80=80- "8be4df61-93ca-11d2-aa0d-00e098032b8c" is EFI_GLOBAL_VA=
RIABLE which is defined in
      UEFI specification.

[Test]
I tested this feature with x86_64.

This is a prototype patch.
So, any comments are welcome.

 Signed-off-by: Seiji Aguchi <seiji.aguchi@hds.com>

---
 Documentation/kernel-parameters.txt |    9 +++
 arch/ia64/kernel/efi.c              |    4 +
 arch/x86/platform/efi/efi.c         |  135 +++++++++++++++++++++++++++++++=
++++
 include/linux/efi.h                 |    4 +
 init/main.c                         |    5 +-
 5 files changed, 156 insertions(+), 1 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-par=
ameters.txt
index b72e071..10212a9 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1778,6 +1778,15 @@ and is between 256 and 4096 characters. It is define=
d in the file
 			This can be set from sysctl after boot.
 			See Documentation/sysctl/vm.txt for details.
=20
+	nvram_kmsg_dump_enable [X86]
+			Enable kmsg_dump for NVRAM
+
+	nvram_kmsg_dump_len=3Dn [X86]
+			Sets the buffer size of kmsg_dump for NVRAM, in bytes.
+			Format: { n | nk | nM }
+			n must be a power of two.  The default size
+			is 1024.
+
 	ohci1394_dma=EArly	[HW] enable debugging via the ohci1394 driver.
 			See Documentation/debugging-via-ohci1394.txt for more
 			info.
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index a0f0019..6ba22aa 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -1366,3 +1366,7 @@ vmcore_find_descriptor_size (unsigned long address)
 	return ret;
 }
 #endif
+
+void nvram_kmsg_dump_init(void)
+{
+}
diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index 0fe27d7..1499fb6 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -37,6 +37,10 @@
 #include <linux/io.h>
 #include <linux/reboot.h>
 #include <linux/bcd.h>
+#include <linux/kmsg_dump.h>
+#include <linux/nls.h>
+#include <linux/slab_def.h>
+#include <linux/gfp.h>
=20
 #include <asm/setup.h>
 #include <asm/efi.h>
@@ -59,6 +63,18 @@ struct efi_memory_map memmap;
 static struct efi efi_phys __initdata;
 static efi_system_table_t efi_systab __initdata;
=20
+int nvram_kmsg_dump_enabled;
+#define LINUX_KMSG_DUMP_PREFIX "LinuxKmsgDump"
+#define LINUX_KMSG_DUMP_LEN 18
+#define MAX_ENTRY 32
+#define SET_VARIABLE_LEN 1024
+static char kmsg_dump_value[LINUX_KMSG_DUMP_LEN];
+static efi_char16_t kmsg_dump_value_utf16[MAX_ENTRY][LINUX_KMSG_DUMP_LEN];
+static char __nvram_kmsg_dump_buf[SET_VARIABLE_LEN];
+static char *nvram_kmsg_dump_buf =3D __nvram_kmsg_dump_buf;
+static int nvram_kmsg_dump_len =3D SET_VARIABLE_LEN;
+static struct kmsg_dumper nvram_kmsg_dumper;
+
 static int __init setup_noefi(char *arg)
 {
 	efi_enabled =3D 0;
@@ -611,3 +627,122 @@ u64 efi_mem_attributes(unsigned long phys_addr)
 	}
 	return 0;
 }
+
+static int __init setup_nvram_kmsg_dump_enable(char *arg)
+{
+	nvram_kmsg_dump_enabled =3D 1;
+	return 0;
+}
+__setup("nvram_kmsg_dump_enable", setup_nvram_kmsg_dump_enable);
+
+static int __init setup_nvram_kmsg_dump_len(char *str)
+{
+	unsigned size =3D memparse(str, &str);
+
+	if (!efi_enabled) {
+		printk(KERN_INFO "setup_nvram_kmsg_dump_len: EFI is disabled\n");
+		return 1;
+	}
+
+	if (size)
+		size =3D roundup_pow_of_two(size);
+	if (size > nvram_kmsg_dump_len) {
+		char *new_nvram_kmsg_dump;
+
+		new_nvram_kmsg_dump =3D alloc_bootmem(size);
+		if (!new_nvram_kmsg_dump) {
+			printk(KERN_WARNING "nvram_kmsg_dump_len: \
+allocation failed\n");
+			return 1;
+		}
+		nvram_kmsg_dump_len =3D size;
+		nvram_kmsg_dump_buf =3D new_nvram_kmsg_dump;
+	}
+	printk(KERN_NOTICE "nvram_kmsg_dump_len: %d\n", nvram_kmsg_dump_len);
+
+	return 0;
+
+}
+__setup("nvram_kmsg_dump_len=3D", setup_nvram_kmsg_dump_len);
+
+static void nvram_do_kmsg_dump(struct kmsg_dumper *dumper,
+	enum kmsg_dump_reason reason, const char *s1, unsigned long l1,
+	const char *s2, unsigned long l2)
+{
+	unsigned long s1_start, s2_start, l1_cpy, l2_cpy;
+	unsigned long attribute =3D 0xf, total, tmp, cpy_size;
+	int i;
+	efi_status_t efi_status;
+	void *tmp_buf;
+
+	l2_cpy =3D min(l2, (unsigned long)nvram_kmsg_dump_len);
+	l1_cpy =3D min(l1, (unsigned long)nvram_kmsg_dump_len - l2_cpy);
+
+	s2_start =3D l2 - l2_cpy;
+	s1_start =3D l1 - l1_cpy;
+
+	memcpy(nvram_kmsg_dump_buf, s1 + s1_start, l1_cpy);
+	memcpy(nvram_kmsg_dump_buf + l1_cpy, s2 + s2_start, l2_cpy);
+
+	/* initialize */
+	for (i =3D 0; i < MAX_ENTRY; i++)
+		efi.set_variable(kmsg_dump_value_utf16[i],
+				 &EFI_GLOBAL_VARIABLE_GUID,
+				 attribute, 0, NULL);
+
+	/* write data */
+	total =3D l1_cpy + l2_cpy;
+	tmp_buf =3D (void *)nvram_kmsg_dump_buf + total;
+	cpy_size =3D 0;
+	for (i =3D 0; i < MAX_ENTRY; i++) {
+		tmp =3D min(total - cpy_size, (unsigned long)SET_VARIABLE_LEN);
+		tmp_buf -=3D tmp;
+		efi_status =3D efi.set_variable(kmsg_dump_value_utf16[i],
+					      &EFI_GLOBAL_VARIABLE_GUID,
+					      attribute, tmp, tmp_buf);
+		if (efi_status) {
+			printk(KERN_WARNING "nvram_do_kmsg_dump: \
+set_variable %d failed 0x%lx\n", i, efi_status);
+			efi.set_variable(kmsg_dump_value_utf16[i],
+					 &EFI_GLOBAL_VARIABLE_GUID,
+					 attribute, 0, NULL);
+			tmp_buf +=3D tmp;
+			cpy_size -=3D tmp;
+		}
+		cpy_size +=3D tmp;
+		if (cpy_size >=3D total)
+			break;
+	}
+}
+
+void nvram_kmsg_dump_init(void)
+{
+
+	int i, outlen, err;
+
+	for (i =3D 0; i < MAX_ENTRY; i++) {
+		snprintf(kmsg_dump_value, sizeof(kmsg_dump_value),
+			 "%s%04d", LINUX_KMSG_DUMP_PREFIX, i + 1);
+		outlen =3D utf8s_to_utf16s((u8 *)kmsg_dump_value,
+					 sizeof(kmsg_dump_value),
+					 (wchar_t *)kmsg_dump_value_utf16[i]);
+		if (outlen !=3D LINUX_KMSG_DUMP_LEN - 1) {
+			printk(KERN_ERR
+			       "nvram_kmsg_dump_init: utf8s_to_utf16s %d\n",
+			       outlen);
+		return;
+		}
+	}
+
+	memset(&nvram_kmsg_dumper, 0, sizeof(nvram_kmsg_dumper));
+	nvram_kmsg_dumper.dump =3D nvram_do_kmsg_dump;
+	err =3D kmsg_dump_register(&nvram_kmsg_dumper);
+	if (err) {
+		printk(KERN_ERR "nvram_kmsg_dump_init: kmsg_dump_register %d\n",
+		       err);
+		return;
+	}
+	printk(KERN_NOTICE "nvram_kmsg_dump initialized\n");
+
+	return;
+}
diff --git a/include/linux/efi.h b/include/linux/efi.h
index fb737bc..d0d1a3c 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -300,6 +300,7 @@ extern void efi_initialize_iomem_resources(struct resou=
rce *code_resource,
 extern unsigned long efi_get_time(void);
 extern int efi_set_rtc_mmss(unsigned long nowtime);
 extern struct efi_memory_map memmap;
+extern void nvram_kmsg_dump_init(void);
=20
 /**
  * efi_range_is_wc - check the WC bit on an address range
@@ -333,11 +334,14 @@ extern int __init efi_setup_pcdp_console(char *);
 #ifdef CONFIG_EFI
 # ifdef CONFIG_X86
    extern int efi_enabled;
+   extern int nvram_kmsg_dump_enabled;
 # else
 #  define efi_enabled 1
+#  define nvram_kmsg_dump_enabled 1
 # endif
 #else
 # define efi_enabled 0
+# define nvram_kmsg_dump_enabled 0
 #endif
=20
 /*
diff --git a/init/main.c b/init/main.c
index 33c37c3..a8ee2bd 100644
--- a/init/main.c
+++ b/init/main.c
@@ -679,8 +679,11 @@ asmlinkage void __init start_kernel(void)
 	pidmap_init();
 	anon_vma_init();
 #ifdef CONFIG_X86
-	if (efi_enabled)
+	if (efi_enabled) {
 		efi_enter_virtual_mode();
+		if (nvram_kmsg_dump_enabled)
+			nvram_kmsg_dump_init();
+	}
 #endif
 	thread_info_cache_init();
 	cred_init();
--=20
1.7.1


=FF=F4=E8=BA{.n=C7+=89=B7=9F=AE=89=AD=86+%=8A=CB=FF=B1=E9=DD=B6=17=A5=8Aw=
=FF=BA{.n=C7+=89=B7=A5=8A{=B1=FE&=BA=E3=F8=A7=B6=17=9B=A1=DC=A8}=A9=9E=B2=
=C6=A0z=DA&j:+v=89=A8=FE=F8=1E=AF=F9=1E=AEw=A5=FE=8A=E02=8A=DE=99=A8=E8=AD=
=DA&=A2)=DF=A1=ABa=B6=DA=FF=FF=FB=E0z=BF=E4z=B9=DE=97=FA+=83=F9=9A=8E=8A=DD=
=A2j=FF=8Aw=E8=FE=1Bf
