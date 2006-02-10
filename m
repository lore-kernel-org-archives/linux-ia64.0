From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 10 Feb 2006 23:58:41 +0000
Subject: RE: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05AD5D9F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
In-Reply-To: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Moore, Robert" <robert.moore@intel.com>, Thomas Renninger <trenn@suse.de>, "Brown, Len" <len.brown@intel.com>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

> This only contains the output of stores to the ACPI "debug"
> object, not the full trace output. However, "_CRS 0" may help

Ah yes.  I'd dropped the acpi_dbg_level = 0xffffff; while trying
to figure out what was going wrong with CONFIG_ACPI_DEBUG=y.

Putting it back in, 16MB is not enough for log_buf :-(

-Tony
