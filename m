From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 14 Jul 2005 09:15:07 +0000
Subject: [RFC][patch 0/10] Multiple vector domain support
Message-Id: <42D62D1B.8000105@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I'm attaching the series of patches for handling huge number of
interrtupt sources. This patch is to increase vector spaces by
separating processors into some domains. This idea is the same as "per
node IDT" posted by Zwane Mwaikambo at:

    http://marc.theaimsgroup.com/?l=linux-kernel&m2103551401596&w=2

The ia64 linux already have vector sharing to handle huge number of
level-triggered interrupt sources via I/O SAPIC, but I think we also
need per domain vector approach because:

    o Supporting vector shairng for edge-triggered interrupts is
      difficult (or impossible)

    o Vector domain approach has better performance than vector
      sharing

    o Need to support MSI based interrupts

This series of patches is still under development, and has following
TBD items.

    o How to create vector domains

      Need to consider how to create vector domains(per CPU?, per
      node? or others...)

    o MSI support

      Attached patch only supports vector domain for I/O SAPIC
      interrupts. We need to consider how to support vector domain for
      MSI interrupts.

    o /proc interface

    o How to handle CPU hotplug

    o and so on..


Any comments and questions are welcomed.

Thanks,
Kenji Kaneshige


