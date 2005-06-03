From: Ashok Raj <ashok.raj@intel.com>
Date: Fri, 03 Jun 2005 00:34:42 +0000
Subject: [patch 0/2] Support BSP offline for IA64.
Message-Id: <20050603003442.885636000@csdlinux-2.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

This set of patches support offlining a BSP in ia64.

- Chooses different time master instead of 
relying on BSP for tsc sync.
- Recognizes CPEI override option for IA64 via APCI.
- New command line to help test these patches, and turn em on
  via cmd line switches.

Cheers,
Ashok Raj

