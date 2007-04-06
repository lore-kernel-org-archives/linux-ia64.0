From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 06 Apr 2007 17:16:25 +0000
Subject: RE: [PATCH] SGI Altix : fix pcibr_dmamap_ate32() bug
Message-Id: <617E1C2C70743745A92448908E030B2A01535BE8@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070406170439.24071.57637.75833@attica.americas.sgi.com>
In-Reply-To: <20070406170439.24071.57637.75833@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Can you explain this part of the patch?

-#define PCI32_ATE_CO                    (0x1 << 1)
-#define PCI32_ATE_PREC                  (0x1 << 2)
+#define PCI32_ATE_CO                    (0x1 << 1)	/* PIC ASIC ONLY */
+#define PCI32_ATE_PIO                   (0x1 << 1)	/* TIOCP ASIC ONLY */

Why is PCI32_ATE_PIO now the same value as PCI_ATE_CO?

-Tony
