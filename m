From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Thu, 28 Jun 2007 08:30:31 +0000
Subject: [PATCH 0/3] Cleanup in iosapic.c
Message-Id: <468371A7.2060208@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here is a series of patches for cleaning up in iosapic.c.
This patchset is for 2.6.22-rc6. There are following 3 patches.

  [PATCH 1/3]  Remove block structure for locking in iosapic.c
  [PATCH 2/3]  Remove duplicated members in iosapic_rte_info
  [PATCH 3/3]  Cleanup lock order in iosapic_register_intr

For more details, please refer to the header of each patch.

Thanks.
Yasuaki Ishimatsu



