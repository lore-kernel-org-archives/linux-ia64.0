From: =?UTF-8?B?TsOpbWV0aCBNw6FydG9u?= <nm127@freemail.hu>
Date: Sat, 14 May 2011 17:02:51 +0000
Subject: incompatible struct pci_root_info?
Message-Id: <4DCEB5BB.1080202@freemail.hu>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: Julia Lawall <julia@diku.dk>, LKML <linux-kernel@vger.kernel.org>

Hello,

I have found struct pci_root_info declaration at three different places in Linux
kernel 2.6.39-rc6. Two of them are in arch/x86 and one of them is in arch/ia64.

arch/x86/pci/bus_numa.h:8:

	struct pci_root_info {
		char name[12];
		unsigned int res_num;
		struct resource res[RES_NUM];
		int bus_min;
		int bus_max;
		int node;
		int link;
	};

arch/x86/pci/acpi.c:10:

	struct pci_root_info {
		struct acpi_device *bridge;
		char *name;
		unsigned int res_num;
		struct resource *res;
		struct pci_bus *bus;
		int busnum;
	};

arch/ia64/pci/pci.c:133:

	struct pci_root_info {
		struct acpi_device *bridge;
		struct pci_controller *controller;
		char *name;
	};

As far as I know it is OK to have different types on different architectures
with the same name. Is there any reason behind having two struct pci_root_info
delcaration in arch/x86?

Regards,

	Márton Németh
