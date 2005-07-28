From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 28 Jul 2005 07:48:24 +0000
Subject: [PATCH 2.6.13-rc3 0/6] failure of acpi_register_gsi() should be handled
Message-Id: <42E88DC8.7050507@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org
Cc: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

Hi,

Current acpi_register_gsi() function has no way to indicate errors to
its callers even though acpi_register_gsi() can fail to register gsi
because of some reasons (out of memory, lack of interrupt vectors,
incorrect BIOS, and so on). As a result, caller of acpi_register_gsi()
cannot handle the case that acpi_register_gsi() fails. I think failure
of acpi_register_gsi() should be handled properly.

This series of patches changes acpi_register_gsi() to return negative
value on error, and also changes callers of acpi_register_gsi() to
handle failure of acpi_register_gsi().

Thanks,
Kenji Kaneshige

