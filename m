From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Mon, 09 Jan 2017 14:58:32 +0000
Subject: [PATCH v6 14/14] lib: add linker tables test driver
Message-Id: <20170109145833.11502-15-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161222023811.21246-1-mcgrof@kernel.org>
 <20170109145833.11502-1-mcgrof@kernel.org>
In-Reply-To: <20170109145833.11502-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, linux@rasmusvillemoes.dk, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, sparclinux@vger.kernel.org, wangnan0@huawei.com, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, xen-devel@lists.xensource.com, msalter@redhat.com, linux-sh@vger.kernel.org, mpe@ellerman.id.au, joro@8bytes.org, x86@kernel.org, fontana@sharpeleven.org, dsahern@gmail.com, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, linux@roeck-us.net, linux-xtensa@linux-xtensa.org, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb.de, jani.nikula@intel.com, will.deacon@arm.com, rusty@rustcorp.com.au, rostedt@goodmis.org

Add a test drivers for linker tables.

v6: rename table macro as suggested by Andy Shevchenko
v5: added this commit for the first time in this series.

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 lib/Kconfig.debug                        |   6 +
 lib/Makefile                             |   1 +
 lib/test_linktables/Makefile             |  13 +
 lib/test_linktables/test-linktables-00.c |  27 ++
 lib/test_linktables/test-linktables-01.c |  27 ++
 lib/test_linktables/test-linktables-02.c |  27 ++
 lib/test_linktables/test-linktables-03.c |  27 ++
 lib/test_linktables/test-linktables-04.c |  27 ++
 lib/test_linktables/test-linktables.c    | 801 +++++++++++++++++++++++++++=
++++
 lib/test_linktables/test-linktables.h    |  48 ++
 10 files changed, 1004 insertions(+)
 create mode 100644 lib/test_linktables/Makefile
 create mode 100644 lib/test_linktables/test-linktables-00.c
 create mode 100644 lib/test_linktables/test-linktables-01.c
 create mode 100644 lib/test_linktables/test-linktables-02.c
 create mode 100644 lib/test_linktables/test-linktables-03.c
 create mode 100644 lib/test_linktables/test-linktables-04.c
 create mode 100644 lib/test_linktables/test-linktables.c
 create mode 100644 lib/test_linktables/test-linktables.h

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 5655bd95919a..8c99ee3c9fd7 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1827,6 +1827,12 @@ config TEST_HASH
 	  This is intended to help people writing architecture-specific
 	  optimized versions.  If unsure, say N.
=20
+config TEST_LINKTABLES
+	bool "Test linker table functionality"
+	default n
+	help
+	  Enable this option to test the kernel's linker table functionality.
+
 endmenu # runtime tests
=20
 config PROVIDE_OHCI1394_DMA_INIT
diff --git a/lib/Makefile b/lib/Makefile
index 94ed5cc4e89c..b5c5a7a9146c 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -55,6 +55,7 @@ obj-$(CONFIG_TEST_STATIC_KEYS) +=3D test_static_key_base.o
 obj-$(CONFIG_TEST_PRINTF) +=3D test_printf.o
 obj-$(CONFIG_TEST_BITMAP) +=3D test_bitmap.o
 obj-$(CONFIG_TEST_UUID) +=3D test_uuid.o
+obj-$(CONFIG_TEST_LINKTABLES) +=3D test_linktables/
=20
 ifeq ($(CONFIG_DEBUG_KOBJECT),y)
 CFLAGS_kobject.o +=3D -DDEBUG
diff --git a/lib/test_linktables/Makefile b/lib/test_linktables/Makefile
new file mode 100644
index 000000000000..a1a67d7fd57a
--- /dev/null
+++ b/lib/test_linktables/Makefile
@@ -0,0 +1,13 @@
+__LINKTABLE_TESTS :=3D $(shell find ./ -name test-linktables-\*.c | wc -l)
+ccflags-y +=3D -D__LINKTABLE_TESTS=3D$(__LINKTABLE_TESTS)
+
+# Keep these disorganized, if linker tables did not work then
+# things would not be ordered for us automatically at link time.
+# Linker tables grants us the ability to be explicit about
+# order.
+obj-$(CONFIG_TEST_LINKTABLES) +=3D test-linktables-04.o
+obj-$(CONFIG_TEST_LINKTABLES) +=3D test-linktables-02.o
+obj-$(CONFIG_TEST_LINKTABLES) +=3D test-linktables-01.o
+obj-$(CONFIG_TEST_LINKTABLES) +=3D test-linktables-03.o
+obj-$(CONFIG_TEST_LINKTABLES) +=3D test-linktables-00.o
+obj-$(CONFIG_TEST_LINKTABLES) +=3D test-linktables.o
diff --git a/lib/test_linktables/test-linktables-00.c b/lib/test_linktables=
/test-linktables-00.c
new file mode 100644
index 000000000000..ea162bd69179
--- /dev/null
+++ b/lib/test_linktables/test-linktables-00.c
@@ -0,0 +1,27 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/tables.h>
+#include <linux/printk.h>
+
+#include "test-linktables.h"
+
+static int __init test_linktable_00_init(int input)
+{
+	return 0 * input;
+}
+
+static int __initdata test_linktable_00_init_data(int input)
+{
+	return 0 * input;
+}
+
+static int test_linktable_00(int input)
+{
+	return 0 * input;
+}
+
+test_linktable_init_data(00, test_linktable_00_init_data); /* .init.data */
+test_linktable_init_text(00, test_linktable_00_init); /* .init.text */
+test_linktable(00, test_linktable_00); /* .data */
+test_linktable_text(00, test_linktable_00); /* .text */
+test_linktable_rodata(00, test_linktable_00); /* .rodata */
diff --git a/lib/test_linktables/test-linktables-01.c b/lib/test_linktables=
/test-linktables-01.c
new file mode 100644
index 000000000000..39578990fd59
--- /dev/null
+++ b/lib/test_linktables/test-linktables-01.c
@@ -0,0 +1,27 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/tables.h>
+#include <linux/printk.h>
+
+#include "test-linktables.h"
+
+static int __init test_linktable_01_init(int input)
+{
+	return 1 * input;
+}
+
+static int __initdata test_linktable_01_init_data(int input)
+{
+	return 1 * input;
+}
+
+static int test_linktable_01(int input)
+{
+	return 1 * input;
+}
+
+test_linktable_init_data(01, test_linktable_01_init_data); /* .init.data */
+test_linktable_init_text(01, test_linktable_01_init); /* .init.text */
+test_linktable(01, test_linktable_01); /* .data */
+test_linktable_text(01, test_linktable_01); /* .text */
+test_linktable_rodata(01, test_linktable_01); /* .rodata */
diff --git a/lib/test_linktables/test-linktables-02.c b/lib/test_linktables=
/test-linktables-02.c
new file mode 100644
index 000000000000..7f4b34240ecb
--- /dev/null
+++ b/lib/test_linktables/test-linktables-02.c
@@ -0,0 +1,27 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/tables.h>
+#include <linux/printk.h>
+
+#include "test-linktables.h"
+
+static int __init test_linktable_02_init(int input)
+{
+	return 2 * input;
+}
+
+static int __initdata test_linktable_02_init_data(int input)
+{
+	return 2 * input;
+}
+
+static int test_linktable_02(int input)
+{
+	return 2 * input;
+}
+
+test_linktable_init_data(02, test_linktable_02_init_data); /* .init.data */
+test_linktable_init_text(02, test_linktable_02_init); /* .init.text */
+test_linktable(02, test_linktable_02); /* .data */
+test_linktable_text(02, test_linktable_02); /* .text */
+test_linktable_rodata(02, test_linktable_02); /* .rodata */
diff --git a/lib/test_linktables/test-linktables-03.c b/lib/test_linktables=
/test-linktables-03.c
new file mode 100644
index 000000000000..47ca77e30c24
--- /dev/null
+++ b/lib/test_linktables/test-linktables-03.c
@@ -0,0 +1,27 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/tables.h>
+#include <linux/printk.h>
+
+#include "test-linktables.h"
+
+static int __init test_linktable_03_init(int input)
+{
+	return 3 * input;
+}
+
+static int __initdata test_linktable_03_init_data(int input)
+{
+	return 3 * input;
+}
+
+static int test_linktable_03(int input)
+{
+	return 3 * input;
+}
+
+test_linktable_init_data(03, test_linktable_03_init_data); /* .init.data */
+test_linktable_init_text(03, test_linktable_03_init); /* .init.text */
+test_linktable(03, test_linktable_03); /* .data */
+test_linktable_text(03, test_linktable_03); /* .text */
+test_linktable_rodata(03, test_linktable_03); /* .rodata */
diff --git a/lib/test_linktables/test-linktables-04.c b/lib/test_linktables=
/test-linktables-04.c
new file mode 100644
index 000000000000..4123e0e16715
--- /dev/null
+++ b/lib/test_linktables/test-linktables-04.c
@@ -0,0 +1,27 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/tables.h>
+#include <linux/printk.h>
+
+#include "test-linktables.h"
+
+static int __init test_linktable_04_init(int input)
+{
+	return 4 * input;
+}
+
+static int __initdata test_linktable_04_init_data(int input)
+{
+	return 4 * input;
+}
+
+static int test_linktable_04(int input)
+{
+	return 4 * input;
+}
+
+test_linktable_init_data(04, test_linktable_04_init_data); /* .init.data */
+test_linktable_init_text(04, test_linktable_04_init); /* .init.text */
+test_linktable(04, test_linktable_04); /* .data */
+test_linktable_text(04, test_linktable_04); /* .text */
+test_linktable_rodata(04, test_linktable_04); /* .rodata */
diff --git a/lib/test_linktables/test-linktables.c b/lib/test_linktables/te=
st-linktables.c
new file mode 100644
index 000000000000..b78fb5b554cb
--- /dev/null
+++ b/lib/test_linktables/test-linktables.c
@@ -0,0 +1,801 @@
+/*
+ * Linker table test driver
+ *
+ * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of copyleft-next (version 0.3.1 or later) as published
+ * at http://copyleft-next.org/.
+ */
+
+/*
+ * This driver provides an interface to trigger and test the linker table =
API
+ * through a series of configurations and a few triggers. This driver
+ * must be built-in as linker tables currently lack generalized modular
+ * support -- additional work is required on each module right now if you
+ * want to use linker tables, in the future we may make this much easier.
+ * For now just build this into your kernel.
+ *
+ * echo -n .text > /sys/devices/virtual/misc/test_linktable/config_section=
_name
+ * echo -n 3 > /sys/devices/virtual/misc/test_linktable/config_input
+ * echo 1 > /sys/devices/virtual/misc/test_linktable/trigger_config
+ * cat /sys/devices/virtual/misc/test_linktable/test_result
+ * 30
+ *
+ * echo -n .data > /sys/devices/virtual/misc/test_linktable/config_section=
_name
+ * echo -n .text > /sys/devices/virtual/misc/test_linktable/config_section=
_name
+ * echo -n .rodata > /sys/devices/virtual/misc/test_linktable/config_secti=
on_name
+ *
+ * To check the configuration:
+ *
+ * cat /sys/devices/virtual/misc/test_linktable/config
+ *
+ * NUM_TESTS
+ *    =E2=88=91        test(n, input)
+ *   n=3D0
+ *
+ * Each linker table entry on each section has a series of entries. Each e=
ntry
+ * has a function which just multiplies the test case number by input valu=
e.
+ *
+ * ...
+ * test-linktables-03.c multiplies (3 * input)
+ * test-linktables-04.c multiplies (4 * input)
+ * ...
+ *
+ * A full run on a section produces the sum of these values. So with input=
 set
+ * to 3 we have:
+ *
+ * (0 * 3) + (1 * 3) + (2 * 3) + (3 * 3) + (4 * 3)
+ *    0    +    3    +    6    +   9     +  12
+ *                    30
+ *
+ * This is nothing important, its just a basic test. We had to pick someth=
ing.
+ * Other than the above tests, this also demos and shows proper const use =
on
+ * all sections which we need as read-only: .text, .init.text, .rodata.
+ * Furthermore it does a silly write test to ensure write works on .data a=
nd
+ * init.data. Since the read-only sections use const we obviously are forc=
ed
+ * by the compiler to not be able to write to these sections.
+ *
+ * One of the more important items, the order, is tested. We could develop
+ * a fancy simple math algorithm that depends on order for correctness but
+ * instead we just annotate the expected order as we run. If the order lis=
ted
+ * on test->expected does not match with the actual order a routine was run
+ * in then we fail and complain.
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/tables.h>
+#include <linux/printk.h>
+#include <linux/module.h>
+#include <linux/miscdevice.h>
+#include <linux/vmalloc.h>
+#include <linux/slab.h>
+
+#include "test-linktables.h"
+
+#define NUM_TESTS __LINKTABLE_TESTS
+
+struct linktable_test_device *__test_dev =3D NULL;
+static bool init_completed =3D false;
+
+static const char *test_dev_name =3D "test_linktable";
+
+/*
+ * Used for the default test to start configuration with if we reset the
+ * test from scratch. Don't use .init.* sections given we can only test
+ * these on init, when init_completed is true we can't .init.* section
+ * code anymore.
+ */
+#define TEST_SECTION_START ".data"
+
+DEFINE_LINKTABLE(struct test_linktable, test_fns_data);
+DEFINE_LINKTABLE_TEXT(struct test_linktable, test_fns_text);
+DEFINE_LINKTABLE_RO(struct test_linktable, test_fns_rodata);
+DEFINE_LINKTABLE_INIT(struct test_linktable, test_fns_init_text);
+DEFINE_LINKTABLE_INIT_DATA(struct test_linktable, test_fns_init_data);
+
+struct test_config {
+	char *section_name;
+	int input;
+	int test_result;
+};
+
+/**
+ * linktable_test_device - test device to help test linker tables
+ *
+ * @dev_idx: unique ID for test device
+ * @misc_dev: we use a misc device under the hood
+ * @dev: pointer to misc_dev's own struct device
+ * @config_mutex: protects configuration of test
+ * @trigger_mutex: the test trigger can only be fired once at a time
+ */
+struct linktable_test_device {
+	struct test_config config;
+	struct miscdevice misc_dev;
+	struct device *dev;
+	struct mutex config_mutex;
+	struct mutex trigger_mutex;
+	unsigned int num_called;
+};
+
+/**
+ * enum linktable_test_case - linker table test case
+ *
+ * @TEST_LINKTABLE_INIT: tests .init.text (this is all const)
+ * @TEST_LINKTABLE_INIT_DATA: tests .init.data
+ * @TEST_LINKTABLE: tests .data
+ * @TEST_LINKTABLE_TEXT: tests .text (this is all const)
+ * @TEST_LINKTABLE_RO: tests .rodata (this is all const)
+ */
+enum linktable_test_case {
+	__TEST_LINKTABLE_INVALID =3D 0,
+
+	TEST_LINKTABLE_INIT,
+	TEST_LINKTABLE_INIT_DATA,
+	TEST_LINKTABLE,
+	TEST_LINKTABLE_TEXT,
+	TEST_LINKTABLE_RO,
+};
+
+static struct miscdevice *dev_to_misc_dev(struct device *dev)
+{
+	return dev_get_drvdata(dev);
+}
+
+static
+struct linktable_test_device *misc_dev_to_test_dev(struct miscdevice *misc=
_dev)
+{
+	return container_of(misc_dev, struct linktable_test_device, misc_dev);
+}
+
+static struct linktable_test_device *dev_to_test_dev(struct device *dev)
+{
+	struct miscdevice *misc_dev;
+
+	misc_dev =3D dev_to_misc_dev(dev);
+
+	return misc_dev_to_test_dev(misc_dev);
+}
+
+static ssize_t config_show(struct device *dev,
+			   struct device_attribute *attr,
+			   char *buf)
+{
+	struct linktable_test_device *test_dev =3D dev_to_test_dev(dev);
+	struct test_config *config =3D &test_dev->config;
+	int len =3D 0;
+
+	mutex_lock(&test_dev->config_mutex);
+
+	len +=3D snprintf(buf, PAGE_SIZE,
+			"Custom trigger configuration for: %s\n",
+			dev_name(dev));
+
+	if (config->section_name)
+		len +=3D snprintf(buf+len, PAGE_SIZE,
+				"section name:\t%s\n",
+				config->section_name);
+	else
+		len +=3D snprintf(buf+len, PAGE_SIZE,
+				"default name:\tEMTPY\n");
+
+	mutex_unlock(&test_dev->config_mutex);
+
+	return len;
+}
+static DEVICE_ATTR_RO(config);
+
+static int write_test(struct test_linktable *test, int write_val)
+{
+	test->write_test =3D write_val;
+	if (test->write_test !=3D write_val) {
+		pr_warn("Write test failed\n");
+		return -EPERM;
+	}
+	return 0;
+}
+
+static int __test_linktable(struct linktable_test_device *test_dev,
+			    struct test_linktable *test)
+{
+	struct test_config *config =3D &test_dev->config;
+	int rc;
+
+	if (test->expected !=3D test_dev->num_called) {
+		pr_warn("test routine ID %d called on order %d\n",
+			test->expected, test_dev->num_called);
+		return -EINVAL;
+	}
+
+	rc =3D write_test(test, test->expected+1);
+	if (rc)
+		return rc;
+
+	rc =3D test->op(config->input);
+	test_dev->num_called++;
+
+	return rc;
+}
+
+static int __test_linktable_ro(struct linktable_test_device *test_dev,
+			       const struct test_linktable *test)
+{
+	struct test_config *config =3D &test_dev->config;
+	int rc;
+
+	if (test->expected !=3D test_dev->num_called) {
+		pr_info("test routine ID %d called on order %d\n",
+			test->expected, test_dev->num_called);
+		return -EINVAL;
+	}
+
+	/*
+	 * Note, compiler would complain if we tried write_test() so
+	 * no need to test that.
+	 */
+
+	rc =3D test->op(config->input);
+	test_dev->num_called++;
+
+	return rc;
+}
+
+static enum linktable_test_case get_test_case(const char *section_name)
+{
+	if (strcmp(".init.text", section_name) =3D 0)
+		return TEST_LINKTABLE_INIT;
+	if (strcmp(".init.data", section_name) =3D 0)
+		return TEST_LINKTABLE_INIT_DATA;
+	if (strcmp(".data", section_name) =3D 0)
+		return TEST_LINKTABLE;
+	if (strcmp(".text", section_name) =3D 0)
+		return TEST_LINKTABLE_TEXT;
+	if (strcmp(".rodata", section_name) =3D 0)
+		return TEST_LINKTABLE_TEXT;
+
+	return __TEST_LINKTABLE_INVALID;
+}
+
+static int __run_sanity_test(struct linktable_test_device *test_dev,
+			     int num_entries)
+{
+	if (!num_entries) {
+		pr_warn("no tests -- this is invalid\n");
+		return -EINVAL;
+	}
+
+	pr_debug("number of tests: %d\n", num_entries);
+
+	if (num_entries !=3D NUM_TESTS) {
+		pr_warn("expected: %d test\n", NUM_TESTS);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int __init run_init_text_test(struct linktable_test_device *test_de=
v)
+{
+	int ret, total =3D 0;
+	const struct test_linktable *test;
+	unsigned int num_entries =3D LINKTABLE_SIZE(test_fns_init_text);
+
+	ret =3D __run_sanity_test(test_dev, num_entries);
+	if (ret)
+		return ret;
+
+	linktable_for_each(test, test_fns_init_text)
+		total +=3D __test_linktable_ro(test_dev, test);
+
+	return total;
+}
+
+static int __init run_init_data_test(struct linktable_test_device *test_de=
v)
+{
+	int ret, total =3D 0;
+	struct test_linktable *test;
+	unsigned int num_entries =3D LINKTABLE_SIZE(test_fns_init_data);
+
+	ret =3D __run_sanity_test(test_dev, num_entries);
+	if (ret)
+		return ret;
+
+	linktable_for_each(test, test_fns_init_data)
+		total +=3D __test_linktable(test_dev, test);
+
+	return total;
+}
+
+static int run_data_test(struct linktable_test_device *test_dev)
+{
+	int ret, total =3D 0;
+	struct test_linktable *test;
+	unsigned int num_entries =3D LINKTABLE_SIZE(test_fns_data);
+
+	ret =3D __run_sanity_test(test_dev, num_entries);
+	if (ret)
+		return ret;
+
+	linktable_for_each(test, test_fns_data)
+		total +=3D __test_linktable(test_dev, test);
+
+	return total;
+}
+
+static int run_text_test(struct linktable_test_device *test_dev)
+{
+	int ret, total =3D 0;
+	const struct test_linktable *test;
+	unsigned int num_entries =3D LINKTABLE_SIZE(test_fns_text);
+
+	ret =3D __run_sanity_test(test_dev, num_entries);
+	if (ret)
+		return ret;
+
+	linktable_for_each(test, test_fns_text)
+		total +=3D __test_linktable_ro(test_dev, test);
+
+	return total;
+}
+
+static int run_rodata_test(struct linktable_test_device *test_dev)
+{
+	int ret, total =3D 0;
+	const struct test_linktable *test;
+	unsigned int num_entries =3D LINKTABLE_SIZE(test_fns_rodata);
+
+	ret =3D __run_sanity_test(test_dev, num_entries);
+	if (ret)
+		return ret;
+
+	linktable_for_each(test, test_fns_rodata)
+		total +=3D __test_linktable_ro(test_dev, test);
+
+	return total;
+}
+
+static int __ref __trigger_config_run(struct linktable_test_device *test_d=
ev)
+{
+	enum linktable_test_case test_case;
+	struct test_config *config =3D &test_dev->config;
+
+	test_dev->num_called =3D 0;
+	test_case =3D get_test_case(config->section_name);
+
+	switch (test_case) {
+	case TEST_LINKTABLE_INIT:
+		if (!init_completed)
+			return run_init_text_test(test_dev);
+		else
+			return -EACCES;
+	case TEST_LINKTABLE_INIT_DATA:
+		if (!init_completed)
+			return run_init_data_test(test_dev);
+		else
+			return -EACCES;
+	case TEST_LINKTABLE:
+		return run_data_test(test_dev);
+	case TEST_LINKTABLE_TEXT:
+		return run_text_test(test_dev);
+	case TEST_LINKTABLE_RO:
+		return run_rodata_test(test_dev);
+	default:
+		pr_warn("Invalid test case requested: %s\n",
+			config->section_name);
+		return -EINVAL;
+	}
+}
+
+static int trigger_config_run(struct linktable_test_device *test_dev)
+{
+	struct test_config *config =3D &test_dev->config;
+	int rc;
+
+	mutex_lock(&test_dev->trigger_mutex);
+	mutex_lock(&test_dev->config_mutex);
+
+	pr_debug("running test on '%s'\n", config->section_name);
+
+	rc =3D __trigger_config_run(test_dev);
+
+	config->test_result =3D rc;
+	pr_debug("result: %d\n", rc);
+
+	if (rc < 0) {
+		rc =3D -EINVAL;
+		goto out;
+	}
+
+	rc =3D 0;
+
+out:
+	mutex_unlock(&test_dev->config_mutex);
+	mutex_unlock(&test_dev->trigger_mutex);
+
+	return rc;
+}
+
+static ssize_t
+trigger_config_store(struct device *dev,
+		     struct device_attribute *attr,
+		     const char *buf, size_t count)
+{
+	struct linktable_test_device *test_dev =3D dev_to_test_dev(dev);
+	int rc;
+
+	rc =3D trigger_config_run(test_dev);
+	if (rc)
+		goto out;
+
+	rc =3D count;
+out:
+	return rc;
+}
+static DEVICE_ATTR_WO(trigger_config);
+
+/*
+ * XXX: move to kstrncpy() once merged.
+ *
+ * Users should use kfree_const() when freeing these.
+ */
+static int __kstrncpy(char **dst, const char *name, size_t count, gfp_t gf=
p)
+{
+	*dst =3D kstrndup(name, count, gfp);
+	if (!*dst)
+		return -ENOSPC;
+	return count;
+}
+
+static int config_copy_section_name(struct test_config *config,
+				    const char *name,
+				    size_t count)
+{
+	return __kstrncpy(&config->section_name, name, count, GFP_KERNEL);
+}
+
+static void __linktable_config_free(struct test_config *config)
+{
+	kfree_const(config->section_name);
+	config->section_name =3D NULL;
+}
+
+static void linktable_config_free(struct linktable_test_device *test_dev)
+{
+	struct test_config *config =3D &test_dev->config;
+
+	mutex_lock(&test_dev->config_mutex);
+	__linktable_config_free(config);
+	mutex_unlock(&test_dev->config_mutex);
+}
+
+static ssize_t config_section_name_store(struct device *dev,
+					 struct device_attribute *attr,
+					 const char *buf, size_t count)
+{
+	struct linktable_test_device *test_dev =3D dev_to_test_dev(dev);
+	struct test_config *config =3D &test_dev->config;
+	int rc;
+
+	mutex_lock(&test_dev->config_mutex);
+	rc =3D config_copy_section_name(config, buf, count);
+	mutex_unlock(&test_dev->config_mutex);
+
+	return rc;
+}
+
+/*
+ * As per sysfs_kf_seq_show() the buf is max PAGE_SIZE.
+ */
+static ssize_t config_test_show_str(struct mutex *config_mutex,
+				    char *dst,
+				    char *src)
+{
+	int len;
+
+	mutex_lock(config_mutex);
+	len =3D snprintf(dst, PAGE_SIZE, "%s\n", src);
+	mutex_unlock(config_mutex);
+
+	return len;
+}
+
+static ssize_t config_section_name_show(struct device *dev,
+					struct device_attribute *attr,
+					char *buf)
+{
+	struct linktable_test_device *test_dev =3D dev_to_test_dev(dev);
+	struct test_config *config =3D &test_dev->config;
+
+	return config_test_show_str(&test_dev->config_mutex, buf,
+				    config->section_name);
+}
+static DEVICE_ATTR(config_section_name, 0644, config_section_name_show,
+		   config_section_name_store);
+
+static int trigger_config_run_named(struct linktable_test_device *test_dev,
+				    const char *section_name)
+{
+	int copied;
+	struct test_config *config =3D &test_dev->config;
+
+	mutex_lock(&test_dev->config_mutex);
+	copied =3D config_copy_section_name(config, section_name,
+					  strlen(section_name));
+	mutex_unlock(&test_dev->config_mutex);
+
+	if (copied <=3D0 || copied !=3D strlen(section_name))
+		return -EINVAL;
+
+	return trigger_config_run(test_dev);
+}
+
+static int __linktable_config_init(struct test_config *config)
+{
+	int ret;
+
+	ret =3D config_copy_section_name(config, TEST_SECTION_START,
+				       strlen(TEST_SECTION_START));
+	if (ret < 0)
+		goto out;
+
+	config->input =3D 3;
+	config->test_result =3D 0;
+
+out:
+	return ret;
+}
+
+static ssize_t reset_store(struct device *dev,
+			   struct device_attribute *attr,
+			   const char *buf, size_t count)
+{
+	struct linktable_test_device *test_dev =3D dev_to_test_dev(dev);
+	struct test_config *config =3D &test_dev->config;
+	int ret;
+
+	mutex_lock(&test_dev->trigger_mutex);
+	mutex_lock(&test_dev->config_mutex);
+
+	__linktable_config_free(config);
+
+	ret =3D __linktable_config_init(config);
+	if (ret < 0) {
+		ret =3D -ENOMEM;
+		dev_err(dev, "could not alloc settings for config trigger: %d\n",
+		       ret);
+		goto out;
+	}
+
+	dev_info(dev, "reset\n");
+	ret =3D count;
+
+out:
+	mutex_unlock(&test_dev->config_mutex);
+	mutex_unlock(&test_dev->trigger_mutex);
+
+	return ret;
+}
+static DEVICE_ATTR_WO(reset);
+
+static int test_dev_config_update_int(struct linktable_test_device *test_d=
ev,
+				      const char *buf, size_t size,
+				      int *config)
+{
+	char *end;
+	long new =3D simple_strtol(buf, &end, 0);
+	if (end =3D buf || new > INT_MAX || new < INT_MIN)
+		return -EINVAL;
+	mutex_lock(&test_dev->config_mutex);
+	*config =3D new;
+	mutex_unlock(&test_dev->config_mutex);
+	/* Always return full write size even if we didn't consume all */
+	return size;
+}
+
+static ssize_t test_dev_config_show_int(struct linktable_test_device *test=
_dev,
+					char *buf,
+					int config)
+{
+	int val;
+
+	mutex_lock(&test_dev->config_mutex);
+	val =3D config;
+	mutex_unlock(&test_dev->config_mutex);
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", val);
+}
+
+static ssize_t test_result_store(struct device *dev,
+				 struct device_attribute *attr,
+				 const char *buf, size_t count)
+{
+	struct linktable_test_device *test_dev =3D dev_to_test_dev(dev);
+	struct test_config *config =3D &test_dev->config;
+
+	return test_dev_config_update_int(test_dev, buf, count,
+					  &config->test_result);
+}
+
+static ssize_t config_input_store(struct device *dev,
+				  struct device_attribute *attr,
+				  const char *buf, size_t count)
+{
+	struct linktable_test_device *test_dev =3D dev_to_test_dev(dev);
+	struct test_config *config =3D &test_dev->config;
+
+	return test_dev_config_update_int(test_dev, buf, count,
+					  &config->input);
+}
+
+static ssize_t config_input_show(struct device *dev,
+				 struct device_attribute *attr,
+				 char *buf)
+{
+	struct linktable_test_device *test_dev =3D dev_to_test_dev(dev);
+	struct test_config *config =3D &test_dev->config;
+
+	return test_dev_config_show_int(test_dev, buf, config->input);
+}
+static DEVICE_ATTR(config_input, 0644, config_input_show, config_input_sto=
re);
+
+static ssize_t test_result_show(struct device *dev,
+				struct device_attribute *attr,
+				char *buf)
+{
+	struct linktable_test_device *test_dev =3D dev_to_test_dev(dev);
+	struct test_config *config =3D &test_dev->config;
+
+	return test_dev_config_show_int(test_dev, buf, config->test_result);
+}
+static DEVICE_ATTR(test_result, 0644, test_result_show, test_result_store);
+
+#define LINKTABLE_DEV_ATTR(name)		&dev_attr_##name.attr
+
+static struct attribute *test_dev_attrs[] =3D {
+	LINKTABLE_DEV_ATTR(trigger_config),
+	LINKTABLE_DEV_ATTR(config),
+	LINKTABLE_DEV_ATTR(reset),
+
+	LINKTABLE_DEV_ATTR(config_section_name),
+	LINKTABLE_DEV_ATTR(config_input),
+	LINKTABLE_DEV_ATTR(test_result),
+
+	NULL,
+};
+
+ATTRIBUTE_GROUPS(test_dev);
+
+static int linktable_config_init(struct linktable_test_device *test_dev)
+{
+	struct test_config *config =3D &test_dev->config;
+	int ret;
+
+	mutex_lock(&test_dev->config_mutex);
+	ret =3D __linktable_config_init(config);
+	mutex_unlock(&test_dev->config_mutex);
+
+	return ret;
+}
+
+static struct linktable_test_device *alloc_test_dev_linktable(void)
+{
+	int rc;
+	struct linktable_test_device *test_dev;
+	struct miscdevice *misc_dev;
+
+	test_dev =3D vmalloc(sizeof(struct linktable_test_device));
+	if (!test_dev) {
+		pr_err("Cannot alloc test_dev\n");
+		goto err_out;
+	}
+
+	memset(test_dev, 0, sizeof(struct linktable_test_device));
+
+	mutex_init(&test_dev->config_mutex);
+	mutex_init(&test_dev->trigger_mutex);
+
+	rc =3D linktable_config_init(test_dev);
+	if (rc < 0) {
+		pr_err("Cannot alloc linktable_config_init()\n");
+		goto err_out_free;
+	}
+
+	misc_dev =3D &test_dev->misc_dev;
+
+	misc_dev->minor =3D MISC_DYNAMIC_MINOR;
+	misc_dev->name =3D test_dev_name;
+	misc_dev->groups =3D test_dev_groups;
+
+	return test_dev;
+
+err_out_free:
+	kfree(test_dev);
+err_out:
+	return NULL;
+}
+
+static void free_test_dev_linktable(struct linktable_test_device *test_dev)
+{
+	test_dev->misc_dev.name =3D NULL;
+	vfree(test_dev);
+	test_dev =3D NULL;
+	linktable_config_free(test_dev);
+}
+
+static struct linktable_test_device *register_test_dev_linktable(void)
+{
+	struct linktable_test_device *test_dev =3D NULL;
+	int rc;
+
+	test_dev =3D alloc_test_dev_linktable();
+	if (!test_dev) {
+		return NULL;
+	}
+
+	rc =3D misc_register(&test_dev->misc_dev);
+	if (rc) {
+		pr_err("could not register misc device: %d\n", rc);
+		free_test_dev_linktable(test_dev);
+		return NULL;
+	}
+
+	test_dev->dev =3D test_dev->misc_dev.this_device;
+	dev_dbg(test_dev->dev, "interface ready\n");
+
+	return test_dev;
+}
+
+static int __init test_linktable_init(void)
+{
+	struct linktable_test_device *test_dev;
+	int rc;
+
+	test_dev =3D register_test_dev_linktable();
+	if (!test_dev) {
+		pr_err("Cannot add test linktable device\n");
+		return -ENODEV;
+	}
+
+	rc =3D trigger_config_run_named(test_dev, ".init.text");
+	if (WARN_ON(rc))
+		return rc;
+	rc =3D trigger_config_run_named(test_dev, ".init.data");
+	if (WARN_ON(rc))
+		return rc;
+
+	init_completed =3D true;
+
+	rc =3D trigger_config_run_named(test_dev, ".data");
+	if (WARN_ON(rc))
+		return rc;
+	rc =3D trigger_config_run_named(test_dev, ".text");
+	if (WARN_ON(rc))
+		return rc;
+	rc =3D trigger_config_run_named(test_dev, ".rodata");
+	if (WARN_ON(rc))
+		return rc;
+
+	pr_info("linker table tests: OK!\n");
+
+	return 0;
+}
+late_initcall(test_linktable_init);
+
+static
+void unregister_test_dev_linktable(struct linktable_test_device *test_dev)
+{
+	dev_info(test_dev->dev, "removing interface\n");
+	misc_deregister(&test_dev->misc_dev);
+	free_test_dev_linktable(test_dev);
+}
+
+static void __exit test_linktable_exit(void)
+{
+	struct linktable_test_device *test_dev =3D __test_dev;
+
+	unregister_test_dev_linktable(test_dev);
+}
+module_exit(test_linktable_exit);
+
+MODULE_AUTHOR("Luis R. Rodriguez <mcgrof@kernel.org>");
+MODULE_LICENSE("GPL");
diff --git a/lib/test_linktables/test-linktables.h b/lib/test_linktables/te=
st-linktables.h
new file mode 100644
index 000000000000..c9c9d5c87263
--- /dev/null
+++ b/lib/test_linktables/test-linktables.h
@@ -0,0 +1,48 @@
+#include <linux/tables.h>
+
+struct test_linktable {
+	int expected;
+	int write_test;
+	int (*op)(int input_digit);
+};
+
+#define test_linktable_init_text(__level, __op)				\
+	static LINKTABLE_INIT(test_fns_init_text, __level)		\
+	__test_fn_init_text_##__op =3D {					\
+		.expected =3D __level,					\
+		.op =3D __op,						\
+};
+
+#define test_linktable_init_data(__level, __op)				\
+	static LINKTABLE_INIT_DATA(test_fns_init_data, __level)		\
+	__test_fn_init_data_##__op =3D {					\
+		.expected =3D __level,					\
+		.op =3D __op,						\
+};
+
+#define test_linktable(__level, __op)					\
+	static LINKTABLE(test_fns_data, __level)			\
+	__test_fn_data_##__op =3D {					\
+		.expected =3D __level,					\
+		.op =3D __op,						\
+};
+
+#define test_linktable_text(__level, __op)				\
+	static LINKTABLE_TEXT(test_fns_text, __level)			\
+	__test_fn_text_##__op =3D {					\
+		.expected =3D __level,					\
+		.op =3D __op,						\
+};
+
+#define test_linktable_rodata(__level, __op)				\
+	static LINKTABLE_RO(test_fns_rodata, __level)			\
+	__test_fn_rodata_##__op =3D {					\
+		.expected =3D __level,					\
+		.op =3D __op,						\
+};
+
+DECLARE_LINKTABLE_RO(struct test_linktable, test_fns_init_text);
+DECLARE_LINKTABLE(struct test_linktable, test_fns_init_data);
+DECLARE_LINKTABLE(struct test_linktable, test_fns_data);
+DECLARE_LINKTABLE_RO(struct test_linktable, test_fns_text);
+DECLARE_LINKTABLE_RO(struct test_linktable, test_fns_rodata);
--=20
2.11.0

