From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date: Fri, 24 Mar 2006 06:43:21 +0000
Subject: [PATCH 0/2] cleanup iosapic.c
Message-Id: <87pskcfily.wl%takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

These patches clean up arch/ia64/kernel/iosapic.c.
The changes are as follows:

- [PATCH 1/2] correct some messages and fixes some some minor typos.

- [PATCH 2/2] simplify some condition checks.

For more specifc information, please refer to the header of each patch.
These patches are against 2.6.16. I tested them on Tiger4.

Thanks,
Satoru Takeuchi
