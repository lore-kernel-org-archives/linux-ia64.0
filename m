From: Corentin Labbe <clabbe@baylibre.com>
Date: Thu, 21 Nov 2019 08:14:40 +0000
Subject: [PATCH v2 0/5] agp: minor fixes
Message-Id: <1574324085-4338-1-git-send-email-clabbe@baylibre.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: airlied@redhat.com, airlied@linux.ie, arnd@arndb.de, fenghua.yu@intel.com, gregkh@linuxfoundation.org, tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Corentin Labbe <clabbe@baylibre.com>

Hello

This patch serie fixes some minor problem found in the agp subsystem
There are no change since v1 (posted two years ago)
This is simply a repost for trying to get an answer (gentle ping 6 month
ago got no answer also).

Regards

Corentin Labbe (5):
  agp: remove unused variable size in agp_generic_create_gatt_table
  agp: move AGPGART_MINOR to include/linux/miscdevice.h
  agp: remove unused variable num_segments
  agp: Add bridge parameter documentation
  ia64: agp: Replace empty define with do while

 arch/ia64/include/asm/agp.h |  4 ++--
 drivers/char/agp/frontend.c |  3 +--
 drivers/char/agp/generic.c  | 12 +++++-------
 include/linux/agpgart.h     |  2 --
 include/linux/miscdevice.h  |  1 +
 5 files changed, 9 insertions(+), 13 deletions(-)

-- 
2.23.0
