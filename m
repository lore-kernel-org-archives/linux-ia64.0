From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 30 Jul 2007 02:53:38 +0000
Subject: [PATCH 0/2] vector domain related fixes
Message-Id: <1185764018.3940.54.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here are a patches related to vector domain. Those patches
fix the following problems.

[PATCH 1/2] Fix registered interrupt check

    When I was doing PCI hotplug, I encountered a problem that
    interrupts are not initialized correctly. This problem might
    also happen at driver reloading. The cause of this problem
    is wrong check of registered interrupts.

[PATCH 2/2] Fix possible race in destroy_and_reserve_irq().

    This patch fixes a possible race condition in destroy_and_reserve_irq().

Thanks,
Kenji Kaneshige


