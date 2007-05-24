From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 24 May 2007 18:30:44 +0000
Subject: RE: [PATCH] ia64-acpi section mismatch
Message-Id: <617E1C2C70743745A92448908E030B2A018B0DBA@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070524112210.307857c7.randy.dunlap@oracle.com>
In-Reply-To: <20070524112210.307857c7.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Looks like acpi_get_sysname() can be marked __init...

Agreed ... in fact I checked that into my local tree about
20 minutes ago.  Haven't pushed it out yet.

The "Section mismatch" whack-a-mole game is almost over.  With this
change applied the only one I have left is:

Section mismatch: reference to .init.text:acpi_map_pxm_to_node (between 'acpi_get_node' and 'acpi_lock_ac_dir')


for which the answer *appears* to be to drop the __cpuinit attribute
on acpi_map_pxm_to_node()

-Tony
