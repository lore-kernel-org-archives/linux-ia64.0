From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Fri, 24 Sep 2004 23:51:57 +0000
Subject: Re: PATCH-ACPI based CPU hotplug[6/6]-ACPI Container driver
Message-Id: <20040924165157.F27778@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com> <20040920094719.H14208@unix-os.sc.intel.com>
In-Reply-To: <20040920094719.H14208@unix-os.sc.intel.com>; from anil.s.keshavamurthy@intel.com on Mon, Sep 20, 2004 at 09:47:19AM -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Cc: Len Brown <len.brown@intel.com>, ACPI Developer <acpi-devel@lists.sourceforge.net>, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Mon, Sep 20, 2004 at 09:47:19AM -0700, Keshavamurthy Anil S wrote:
> Changes from previous release:
> 1) Typo fix- ACPI004 to ACPI0004
> 2) Added depends on EXPERIMENTAL in Kconfig file
Refreshed this patch and added printk for ACPI_NOTIFY_BUS_CHECK=20
and for ACPI_NOTIFY_DEVICE_CHECK as no major issues were identified with th=
is patch.


---
Name:container_drv.patch
Status: Tested on 2.6.9-rc1
Signed-off-by: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
Depends:=09
Version: applies on 2.6.9-rc1
Description:
This is the very early version on the Container driver which supports
hotplug notifications on ACPI0004, PNP0A05 and PNP0A06 devices.
	Changes from previous release:
	1) Mergerd the typo fix patch which changes "ACPI004" to "ACPI0004"
---

 linux-2.6.9-rc2-askeshav/drivers/acpi/Kconfig     |   10=20
 linux-2.6.9-rc2-askeshav/drivers/acpi/Makefile    |    1=20
 linux-2.6.9-rc2-askeshav/drivers/acpi/container.c |  344 +++++++++++++++++=
+++++
 linux-2.6.9-rc2-askeshav/include/acpi/container.h |   13=20
 4 files changed, 367 insertions(+), 1 deletion(-)

diff -puN drivers/acpi/Kconfig~container_drv drivers/acpi/Kconfig
--- linux-2.6.9-rc2/drivers/acpi/Kconfig~container_drv	2004-09-24 15:26:33.=
791637629 -0700
+++ linux-2.6.9-rc2-askeshav/drivers/acpi/Kconfig	2004-09-24 15:26:33.88734=
0753 -0700
@@ -133,6 +133,7 @@ config ACPI_HOTPLUG_CPU
 	bool "Processor Hotplug (EXPERIMENTAL)"
 	depends on ACPI_PROCESSOR && HOTPLUG_CPU && EXPERIMENTAL
 	depends on !IA64_SGI_SN
+	select ACPI_CONTAINER
 	default n
 	 ---help---
 	 Select this option if your platform support physical CPU hotplug.
@@ -278,5 +279,12 @@ config X86_PM_TIMER
 	  kernel logs, and/or you are using this on a notebook which
 	  does not yet have an HPET, you should say "Y" here.
=20
-endmenu
+config ACPI_CONTAINER
+	tristate "ACPI0004,PNP0A05 and PNP0A06 Container Driver (EXPERIMENTAL)"
+	depends on ACPI && EXPERIMENTAL
+	default (ACPI_HOTPLUG_MEMORY || ACPI_HOTPLUG_CPU || ACPI_HOTPLUG_IO)
+	 ---help---
+	 	This is the ACPI generic container driver which supports
+		ACPI0004, PNP0A05 and PNP0A06 devices
=20
+endmenu
diff -puN drivers/acpi/Makefile~container_drv drivers/acpi/Makefile
--- linux-2.6.9-rc2/drivers/acpi/Makefile~container_drv	2004-09-24 15:26:33=
.796520442 -0700
+++ linux-2.6.9-rc2-askeshav/drivers/acpi/Makefile	2004-09-24 15:26:33.8883=
17315 -0700
@@ -41,6 +41,7 @@ obj-$(CONFIG_ACPI_FAN)		+=3D fan.o
 obj-$(CONFIG_ACPI_PCI)		+=3D pci_root.o pci_link.o pci_irq.o pci_bind.o
 obj-$(CONFIG_ACPI_POWER)	+=3D power.o
 obj-$(CONFIG_ACPI_PROCESSOR)	+=3D processor.o
+obj-$(CONFIG_ACPI_CONTAINER)	+=3D container.o
 obj-$(CONFIG_ACPI_THERMAL)	+=3D thermal.o
 obj-$(CONFIG_ACPI_SYSTEM)	+=3D system.o event.o
 obj-$(CONFIG_ACPI_DEBUG)	+=3D debug.o
diff -puN /dev/null include/acpi/container.h
--- /dev/null	2004-06-30 13:03:36.000000000 -0700
+++ linux-2.6.9-rc2-askeshav/include/acpi/container.h	2004-09-24 15:26:33.8=
89293878 -0700
@@ -0,0 +1,13 @@
+#ifndef __ACPI_CONTAINER_H
+#define __ACPI_CONTAINER_H
+
+#include <linux/kernel.h>
+
+struct acpi_container {
+	acpi_handle handle;
+	unsigned long sun;
+	int state;
+};
+
+#endif /* __ACPI_CONTAINER_H */
+
diff -puN /dev/null drivers/acpi/container.c
--- /dev/null	2004-06-30 13:03:36.000000000 -0700
+++ linux-2.6.9-rc2-askeshav/drivers/acpi/container.c	2004-09-24 15:26:33.8=
90270440 -0700
@@ -0,0 +1,344 @@
+/*
+ * acpi_container.c  - ACPI Generic Container Driver
+ * ($Revision: )
+ *
+ * Copyright (C) 2004 Anil S Keshavamurthy (anil.s.keshavamurthy@intel.com)
+ * Copyright (C) 2004 Keiichiro Tokunaga (tokunaga.keiich@jp.fujitsu.com)
+ * Copyright (C) 2004 Motoyuki Ito (motoyuki@soft.fujitsu.com)
+ * Copyright (C) 2004 Intel Corp.
+ * Copyright (C) 2004 FUJITSU LIMITED
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=
~~~
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or (at
+ *  your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful, but
+ *  WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License along
+ *  with this program; if not, write to the Free Software Foundation, Inc.,
+ *  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=
~~~
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/types.h>
+#include <linux/acpi.h>
+#include <acpi/acpi_bus.h>
+#include <acpi/acpi_drivers.h>
+#include <acpi/container.h>
+
+#define ACPI_CONTAINER_DRIVER_NAME	"ACPI container driver"
+#define ACPI_CONTAINER_DEVICE_NAME	"ACPI container device"
+#define ACPI_CONTAINER_CLASS		"container"
+
+#define INSTALL_NOTIFY_HANDLER		1
+#define UNINSTALL_NOTIFY_HANDLER	2
+
+#define ACPI_CONTAINER_COMPONENT	0x01000000
+#define _COMPONENT			ACPI_CONTAINER_COMPONENT
+ACPI_MODULE_NAME			("acpi_container")
+
+MODULE_AUTHOR("Anil S Keshavamurthy");
+MODULE_DESCRIPTION(ACPI_CONTAINER_DRIVER_NAME);
+MODULE_LICENSE("GPL");
+
+#define ACPI_STA_PRESENT		(0x00000001)
+
+static int acpi_container_add(struct acpi_device *device);
+static int acpi_container_remove(struct acpi_device *device, int type);
+
+static struct acpi_driver acpi_container_driver =3D {
+	.name =3D		ACPI_CONTAINER_DRIVER_NAME,
+	.class =3D	ACPI_CONTAINER_CLASS,
+	.ids =3D		"ACPI0004,PNP0A05,PNP0A06",
+	.ops =3D		{
+				.add =3D		acpi_container_add,
+				.remove =3D	acpi_container_remove,
+			},
+};
+
+
+/*******************************************************************/
+
+static int
+is_device_present(acpi_handle handle)
+{
+	acpi_handle		temp;
+	acpi_status		status;
+	unsigned long	sta;
+
+	ACPI_FUNCTION_TRACE("is_device_present");
+
+	status =3D acpi_get_handle(handle, "_STA", &temp);
+	if (ACPI_FAILURE(status))
+		return_VALUE(1); /* _STA not found, assmue device present */
+
+	status =3D acpi_evaluate_integer(handle, "_STA", NULL, &sta);
+	if (ACPI_FAILURE(status))
+		return_VALUE(0); /* Firmware error */
+
+	return_VALUE((sta & ACPI_STA_PRESENT) =3D ACPI_STA_PRESENT);
+}
+
+/*******************************************************************/
+static int
+acpi_container_add(struct acpi_device *device)
+{
+	struct acpi_container *container;
+
+	ACPI_FUNCTION_TRACE("acpi_container_add");
+
+	if (!device) {
+		ACPI_DEBUG_PRINT((ACPI_DB_ERROR, "device is NULL\n"));
+		return_VALUE(-EINVAL);
+	}
+
+	container =3D kmalloc(sizeof(struct acpi_container), GFP_KERNEL);
+	if(!container)
+		return_VALUE(-ENOMEM);
+=09
+	memset(container, 0, sizeof(struct acpi_container));
+	container->handle =3D device->handle;
+	strcpy(acpi_device_name(device), ACPI_CONTAINER_DEVICE_NAME);
+	strcpy(acpi_device_class(device), ACPI_CONTAINER_CLASS);
+	acpi_driver_data(device) =3D container;
+
+	ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Device <%s> bid <%s>\n",	\
+		acpi_device_name(device), acpi_device_bid(device)));
+
+
+	return_VALUE(0);
+}
+
+static int
+acpi_container_remove(struct acpi_device *device, int type)
+{
+	acpi_status		status =3D AE_OK;
+	struct acpi_container	*pc =3D NULL;
+	pc =3D (struct acpi_container*) acpi_driver_data(device);
+
+	if (pc)
+		kfree(pc);
+
+	return status;
+}
+
+
+static int
+container_run_sbin_hotplug(struct acpi_device *device, char *action)
+{
+	char *argv[3], *envp[6], action_str[32];
+	int i, ret;
+	int len;
+	char pathname[ACPI_PATHNAME_MAX] =3D {0};
+	acpi_status status;
+	char *container_str;
+	struct acpi_buffer buffer =3D {ACPI_PATHNAME_MAX, pathname};
+
+	ACPI_FUNCTION_TRACE("container_run_sbin_hotplug");
+
+
+	status =3D acpi_get_name(device->handle, ACPI_FULL_PATHNAME, &buffer);
+	if (ACPI_FAILURE(status)) {
+		return(-ENODEV);
+	}
+
+	len =3D strlen("CONTAINER=3D") + strlen(pathname) + 1;
+	container_str =3D kmalloc(len, GFP_KERNEL);
+	if (!container_str)
+		return(-ENOMEM);
+
+	sprintf(container_str, "CONTAINER=3D%s",pathname);
+	sprintf(action_str, "ACTION=3D%s", action);
+
+	i =3D 0;
+	argv[i++] =3D hotplug_path;
+	argv[i++] =3D "container";
+	argv[i] =3D NULL;
+
+	i =3D 0;
+	envp[i++] =3D "HOME=3D/";
+	envp[i++] =3D "PATH=3D/sbin;/bin;/usr/sbin;/usr/bin";
+	envp[i++] =3D action_str;
+	envp[i++] =3D container_str;
+	envp[i++] =3D "PLATFORM=ACPI";
+	envp[i] =3D NULL;
+
+	ret =3D call_usermodehelper(argv[0], argv, envp, 0);
+
+	kfree(container_str);
+	return_VALUE(ret);
+}
+
+static int
+container_device_add(struct acpi_device **device, acpi_handle handle)
+{
+	acpi_handle phandle;
+	struct acpi_device *pdev;
+	int result;
+
+	ACPI_FUNCTION_TRACE("container_device_add");
+
+	if (acpi_get_parent(handle, &phandle)) {
+		return_VALUE(-ENODEV);
+	}
+
+	if (acpi_bus_get_device(phandle, &pdev)) {
+		return_VALUE(-ENODEV);
+	}
+
+	if (acpi_bus_add(device, pdev, handle, ACPI_BUS_TYPE_DEVICE)) {
+		return_VALUE(-ENODEV);
+	}
+
+	result =3D acpi_bus_scan(*device);
+
+	return_VALUE(result);
+}
+
+static void
+container_notify_cb(acpi_handle handle, u32 type, void *context)
+{
+	struct acpi_device		*device =3D NULL;
+	int result;
+	int present;
+	acpi_status status;
+
+	ACPI_FUNCTION_TRACE("container_notify_cb");
+
+	present =3D is_device_present(handle);
+=09
+	switch (type) {
+	case ACPI_NOTIFY_BUS_CHECK:
+		/* Fall through */
+	case ACPI_NOTIFY_DEVICE_CHECK:
+		printk("Container driver received %s event\n",
+			(type =3D ACPI_NOTIFY_BUS_CHECK)?
+			"ACPI_NOTIFY_BUS_CHECK":"ACPI_NOTIFY_DEVICE_CHECK");
+		if (present) {
+			status =3D acpi_bus_get_device(handle, &device);
+			if (ACPI_FAILURE(status) || !device) {
+				result =3D container_device_add(&device, handle);
+				if (!result)
+					container_run_sbin_hotplug(device, "add");
+			} else {
+				/* device exist and this is a remove request */
+				container_run_sbin_hotplug(device, "remove");
+			}
+		}
+		break;
+	case ACPI_NOTIFY_EJECT_REQUEST:
+		if (!acpi_bus_get_device(handle, &device) && device) {
+			container_run_sbin_hotplug(device, "remove");
+		}
+		break;
+	default:
+		break;
+	}
+	return_VOID;
+}
+
+static acpi_status
+container_walk_namespace_cb(acpi_handle handle,
+	u32 lvl,
+	void *context,
+	void **rv)
+{
+	char 				*hid =3D NULL;
+	struct acpi_buffer 		buffer =3D {ACPI_ALLOCATE_BUFFER, NULL};
+	struct acpi_device_info 	*info;
+	acpi_status 			status;
+	int 				*action =3D context;
+
+	ACPI_FUNCTION_TRACE("container_walk_namespace_cb");
+
+	status =3D acpi_get_object_info(handle, &buffer);
+	if (ACPI_FAILURE(status) || !buffer.pointer) {
+		return_ACPI_STATUS(AE_OK);
+	}
+
+	info =3D buffer.pointer;
+	if (info->valid & ACPI_VALID_HID)
+		hid =3D info->hardware_id.value;
+
+	if (hid =3D NULL) {
+		goto end;
+	}
+
+	if (strcmp(hid, "ACPI0004") && strcmp(hid, "PNP0A05") &&
+			strcmp(hid, "PNP0A06")) {
+		goto end;
+	}
+
+	switch(*action) {
+	case INSTALL_NOTIFY_HANDLER:
+		acpi_install_notify_handler(handle,
+			ACPI_SYSTEM_NOTIFY,
+			container_notify_cb,
+			NULL);
+		break;
+	case UNINSTALL_NOTIFY_HANDLER:
+		acpi_remove_notify_handler(handle,
+			ACPI_SYSTEM_NOTIFY,
+			container_notify_cb);
+		break;
+	default:
+		break;
+	}
+
+end:
+	acpi_os_free(buffer.pointer);
+
+	return_ACPI_STATUS(AE_OK);
+}
+
+
+int __init
+acpi_container_init(void)
+{
+	int	result =3D 0;
+	int	action =3D INSTALL_NOTIFY_HANDLER;
+
+	result =3D acpi_bus_register_driver(&acpi_container_driver);
+	if (result < 0) {
+		return(result);
+	}
+
+	/* register notify handler to every container device */
+	acpi_walk_namespace(ACPI_TYPE_DEVICE,
+				     ACPI_ROOT_OBJECT,
+				     ACPI_UINT32_MAX,
+				     container_walk_namespace_cb,
+				     &action, NULL);
+
+	return(0);
+}
+
+void __exit
+acpi_container_exit(void)
+{
+	int			action =3D UNINSTALL_NOTIFY_HANDLER;
+
+	ACPI_FUNCTION_TRACE("acpi_container_exit");
+
+	acpi_walk_namespace(ACPI_TYPE_DEVICE,
+				     ACPI_ROOT_OBJECT,
+				     ACPI_UINT32_MAX,
+				     container_walk_namespace_cb,
+				     &action, NULL);
+
+	acpi_bus_unregister_driver(&acpi_container_driver);
+
+	return_VOID;
+}
+
+module_init(acpi_container_init);
+module_exit(acpi_container_exit);
_

