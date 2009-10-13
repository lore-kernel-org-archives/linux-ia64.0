From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Tue, 13 Oct 2009 09:10:17 +0000
Subject: Re: [PATCH 2/8] bitmap: Introduce bitmap_set, bitmap_clear,
Message-Id: <20091013091017.GA18431@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1255076961-21325-1-git-send-email-akinobu.mita@gmail.com> <1255076961-21325-2-git-send-email-akinobu.mita@gmail.com> <20091009164100.85a36188.akpm@linux-foundation.org> <20091013021818.GA3898@localhost.localdomain>
In-Reply-To: <20091013021818.GA3898@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@suse.de>, Lothar Wassmann <LW@KARO-electronics.de>, linux-usb@vger.kernel.org, Roland Dreier <rolandd@cisco.com>, Yevgeny Petrilin <yevgenyp@mellanox.co.il>, netdev@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-altix@sgi.com

My user space testing exposed off-by-one error find_next_zero_area
in iommu-helper. Some zero area cannot be found by this bug.

Subject: [PATCH] Fix off-by-one error in find_next_zero_area

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
---
 lib/iommu-helper.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/iommu-helper.c b/lib/iommu-helper.c
index 75dbda0..afc58bc 100644
--- a/lib/iommu-helper.c
+++ b/lib/iommu-helper.c
@@ -19,7 +19,7 @@ again:
 	index = (index + align_mask) & ~align_mask;
 
 	end = index + nr;
-	if (end >= size)
+	if (end > size)
 		return -1;
 	for (i = index; i < end; i++) {
 		if (test_bit(i, map)) {
-- 
1.5.4.3

