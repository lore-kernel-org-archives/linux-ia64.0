From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 15 Jan 2004 20:04:10 +0000
Subject: Re: [patch] efivars update for 2.6.1
Message-Id: <16390.62011.1043.575769@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401151936.i0FJaopB001880@snoqualmie.dp.intel.com>
In-Reply-To: <200401151936.i0FJaopB001880@snoqualmie.dp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Tolentino <metolent@snoqualmie.dp.intel.com>
Cc: akpm@osdl.org, davidm@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Matt_Domsch@dell.com, matthew.e.tolentino@intel.com

Well, how about adding the URL to the updated efibootmgr to the
help-text for EFI_VARS?

	--david

+#
+# EFI Driver Configuration
+#
+
+menu "EFI driver support"
+depends on EFI
+
+config EFI_VARS
+	tristate "EFI Variable Support via sysfs"
+	depends on EFI
+	default n
+	---help---
+	  If you say Y here, you are able to get EFI (Extensible Firmware
+	  Interface) variable information via sysfs.  You may read,
+	  write, create, and destroy EFI variables through this interface.
+
+
+endmenu
