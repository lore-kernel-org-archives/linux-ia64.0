From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 19 Jun 2007 08:13:42 +0000
Subject: [RFC][PATCH take2 0/13] Support vector domain on ia64
Message-Id: <46779036.5050602@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here is a series of patches for ia64 vector domain. By these patches, we can
use more than 256 irqs. The patchset is based on existing x86-64 vector domain
code. This is for 2.6.22-rc5 and I tested them on my ia64 box.

Changes from previous patchset:

- rebase to 2.6.22-rc5

- define NR_IRQS as (NR_VECTORS + (32 * NR_CPUS))
  NR_VECTROS equals 256

- bind gsi to irq
  If irq number is changed for each enable/disable, suspend/resume may cause
  some problems. To avoid this problem, bind each gsi to specific irq.

This patchset is just a draft, so there is following TBD, I think.

  o How to migrate irq

    In migration, we don't handle the vector for the pending irqs. Probably
    we should manage it.

There are following 13 patches for ia64 vector domain.

  [PATCH take2 1/13]  Remove block structure for locking in iosapic.c
  [PATCH take2 2/13]  Remove duplicated members in iosapic_rte_info
  [PATCH take2 3/13]  Use per iosapic lock for indirect iosapic register access
  [PATCH take2 4/13]  Cleanup lock order in iosapic_register_intr
  [PATCH take2 5/13]  Use dynamic irq for iosapic interrupts
  [PATCH take2 6/13]  Fix invalid irq vector assumption for iosapic
  [PATCH take2 7/13]  Check if irq is sharable
  [PATCH take2 8/13]  Add mapping table between irq and vector
  [PATCH take2 9/13]  Add support for vector domain
  [PATCH take2 10/13] Support irq migration across domain
  [PATCH take2 11/13] Enable percpu vector domain for IA64_GENERIC
  [PATCH take2 12/13] Enable percpu vector domain for IA64_DIG
  [PATCH take2 13/13] Bind gsi to irq

For more details, please refer to the header of each patch.

Any comments or questions are welcome.

Thanks.
Yasuaki Ishimatsu



