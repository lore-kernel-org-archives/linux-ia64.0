From: Simon Horman <horms@verge.net.au>
Date: Tue, 08 May 2007 09:31:14 +0000
Subject: [patch 0/3] [KEXEC] Use generic elf code on ia64
Message-Id: <20070508093114.767199973@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: fastboot@lists.osdl.org, kexec@lists.infradead.org, linux-ia64@vger.kernel.org
Cc: Nanhai Zou <nanhai.zou@intel.com>, Vivek Goyal <vgoyal@in.ibm.com>, Tony Luck <tony.luck@intel.com>

Hi,

the following series of three patches changes ia64 to use
the generic elf note creation code. I previously posted it as
a single patch, and have broken it up on Nanhai Zou's suggestion
in order to make it easier to review.

-- 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

