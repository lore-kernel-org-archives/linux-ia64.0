From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 11 Oct 2006 22:52:28 +0000
Subject: RE: [PATCH] IA64 export symbols empty_zero_page, ia64_ssc
Message-Id: <617E1C2C70743745A92448908E030B2AA634B8@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061009221135.GB9096@shell0.pdx.osdl.net>
In-Reply-To: <20061009221135.GB9096@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Judith Lebzelter <judith@osdl.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Judith,

+++ linux/arch/ia64/kernel/ia64_ksyms.c	2006-10-09 10:15:18.000000000 -0700

These exports are only needed for the HP simulator ... it seems
probable that the more likely fix is change Kconfig to prevent simscsi
from being built as a module.  I assume that any remaining SKI users
build this into the kernel ... arch/ia64/configs/sim_defconfig sets
CONFIG_HP_SIMSCSI=y for example.

-Tony
