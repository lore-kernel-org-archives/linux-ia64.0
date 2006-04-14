From: Zou Nan hai <nanhai.zou@intel.com>
Date: Fri, 14 Apr 2006 00:26:07 +0000
Subject: [PATCH 0/8] IA64 various hugepage size - Overview
Message-Id: <1144974367.5817.39.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org
Cc: Luck@vger.kernel.org, Tony <tony.luck@intel.com>, Chen@vger.kernel.org, Kenneth W <kenneth.w.chen@intel.com>

This series of patches add support to have different
hugepage sizes for different tasks on IA64.

While still keep the kernel compatible to old applications.

With this patch, application can set it's huge page size via
a prctl syscall. 

Then different hugepage sized applications can co-work together.

Zou Nan hai




