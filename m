From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 15 Aug 2007 16:34:50 +0000
Subject: RE: [PATCH] ia64: default the NUMA node distance when there is no ACPI SLIT
Message-Id: <617E1C2C70743745A92448908E030B2A022DB21A@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <b6b031e56608ee8acf4c84cb1f413403@pinky>
In-Reply-To: <b6b031e56608ee8acf4c84cb1f413403@pinky>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

+	printk(KERN_INFO "Building NUMA distance from ACPI 2.0 SLIT\n");

This printk just looks like noise during boot.  Surely this
is normal behavior on a NUMA system?

+	printk(KERN_INFO "No SLIT table, defaulting NUMA distance\n");

But this one deserves more prominence than just KERN_INFO.  I'd
say that it deserves a KERN_ERR rating (without accurate information
we'll make some highly questionable scheduling and memory placement
decisions).  On the other hand the only way for the end-user to fix
this is to complain to their system vendor to fix firmware.  So perhaps
it is just a KERN_NOTICE.

-Tony
