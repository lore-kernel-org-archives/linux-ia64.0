From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 22 Aug 2007 10:51:33 +0000
Subject: [PATCH 0/2] Spurious interrupt-related fixes
Message-Id: <1187779893.3798.70.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here are patches to fix spurious interrupt-related problems:

  - [PATCH 1/2] Fix unexpected interrupt vector handling
  - [PATCH 2/2] Clear pending interrupts at CPU boot up time

Thanks,
Kenji Kaneshige


