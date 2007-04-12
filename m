From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 12 Apr 2007 18:06:16 +0000
Subject: RE: [PATCH] - Increase max SSI size
Message-Id: <617E1C2C70743745A92448908E030B2A01574435@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070412175819.GA9723@sgi.com>
In-Reply-To: <20070412175819.GA9723@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-	sysfs_cpus = kzalloc(sizeof(struct ia64_cpu) * NR_CPUS, GFP_KERNEL);
+	sysfs_cpus = vmalloc(sizeof(struct ia64_cpu) * NR_CPUS);
+	memset(sysfs_cpus, 0, sizeof(sizeof(struct ia64_cpu) * NR_CPUS));
 	if (!sysfs_cpus)
 		panic("kzalloc in topology_init failed - NR_CPUS too big?");
 

How about having the check "if (!sysfs_cpus)" before the memset()?

-Tony
