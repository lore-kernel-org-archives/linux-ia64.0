From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Tue, 27 Mar 2007 04:43:05 +0000
Subject: [PATCH 0/4] Cleanup patches for iosapic locks
Message-Id: <4608A0D9.7050109@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here is a series of patches for cleaning up iosapic locks. This
contains the following patches.

  o [PATCH 1/4] Remove unnecessary lock indent in iosapi.c
  o [PATCH 2/4] Remove duplicated members in iosapic_rte_info
  o [PATCH 3/4] Use per iosapic lock for indirect iosapic register access
  o [PATCH 4/4] Cleanup lock order in iosapic_register_intr

Please see header of each patch about details.

Thanks,
Kenji Kaneshige

