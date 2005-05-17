From: Prarit Bhargava <prarit@sgi.com>
Date: Tue, 17 May 2005 12:47:08 +0000
Subject: Re: [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver - SN Hotplug Driver
Message-Id: <4289E7CC.4080900@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42835EAB.7010905@sgi.com>
In-Reply-To: <42835EAB.7010905@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Greg KH wrote:
>>+
>>+	while ((pci_bus = pci_find_next_bus(pci_bus))) {
>>+		if (!pci_bus->sysdata)
>>+			continue;
>>+
>>+		rc = sn_pci_bus_valid(pci_bus);
>>+		if (rc != 1) {
>>+			dev_dbg(pci_bus->self, "not a valid hotplug bus\n");
>>+			continue;
>>+		}
>>+		dev_dbg(pci_bus->self, "valid hotplug bus\n");
>>+
>>+		rc = sn_hotplug_slot_register(pci_bus);
>>+		if (!rc)
>>+			registered = 1;
>>+		else {
>>+			registered = 0;
>>+			break;
>>+		}
>>+	}
> 
> 
> How do you recover if you fail the second (or third, or fourth) hotplug bus register?  It
> looks like the code will die a horrible death...
> 

Greg,

The return of sn_hotplug_slot_register is an indication of whether or not all 
slots had been properly registered.

The error handling is in sn_hotplug_slot_register.  If I fail a second, or 
third, or an nth hotplug register, the clean up is done in the following code 
(from sn_hotplug_slot_register).

+               rc = pci_hp_register(bss_hotplug_slot);
+               if (rc)
+                       goto register_err;
+       }
+       dev_dbg(pci_bus->self, "Registered bus with hotplug\n");
+       return rc;
+
+register_err:
+       dev_dbg(pci_bus->self, "bus failed to register with err = %d\n",
+               rc);
+
+alloc_err:
+       if (rc = -ENOMEM)
+               dev_dbg(pci_bus->self, "Memory allocation error\n");
+
+       /* destroy THIS element */
+       if (bss_hotplug_slot)
+               sn_release_slot(bss_hotplug_slot);
+
+       /* destroy anything else on the list */
+       while ((bss_hotplug_slot = sn_hp_destroy()))
+               pci_hp_deregister(bss_hotplug_slot);
+
+       return rc;
+}

P.
