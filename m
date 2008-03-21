From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 21 Mar 2008 23:58:30 +0000
Subject: RE: [PATCH, RFC] Create 'slot' sysfs attributein/sys/devices/system/cpu/cpuN/topology/
Message-Id: <1FE6DD409037234FAB833C420AA843ECE13C6E@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080310222735.GA22619@ldl.fc.hp.com> <1FE6DD409037234FAB833C420AA843ECCBFA9D@orsmsx424.amr.corp.intel.com> <20080319233140.GD16237@ldl.fc.hp.com>
In-Reply-To: <20080319233140.GD16237@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>
Cc: lenb@kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

+	if (ACPI_SUCCESS(acpi_get_handle(pr->handle, "_SUN", &handle))) {
+		status = acpi_evaluate_object(pr->handle,
+						"_SUN", NULL, &buffer);
+		if (ACPI_FAILURE(status))
+			object.integer.value = -1;
+	} else {
+		object.integer.value = -1;
+	}
+	arch_set_topology_slot(pr->id, object.integer.value);
+
 	if (!object.processor.pblk_address)
 		ACPI_DEBUG_PRINT((ACPI_DB_INFO, "No PBLK (NULL address)\n"));
 	else if (object.processor.pblk_length != 6)

I'm still seeing these messages:

 "ACPI: Invalid PBLK length [0]"

for every cpu.  Presumably because "object" is a union and when
you did the "object.integer.value = -1;" you scribbled on some bits
that were needed in the subsequent code.

-Tony
