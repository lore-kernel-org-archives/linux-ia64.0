From: Phil Carmody <ext-phil.2.carmody@nokia.com>
Date: Fri, 10 Sep 2010 10:40:43 +0000
Subject: [PATCH 0/2] ia64: possible module unwind table optimisation
Message-Id: <1284115245-23876-1-git-send-email-ext-phil.2.carmody@nokia.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


This move-to-front linked list optimisation was a huge win on ARM, so I 
checked for other architectures which manage their module unwind tables
in a similar way.

Alas I have no way to test this patch.

Phil
