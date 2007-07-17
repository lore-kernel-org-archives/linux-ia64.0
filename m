From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Tue, 17 Jul 2007 12:20:10 +0000
Subject: [PATCH take3 0/12] Support vector domain on ia64
Message-Id: <469CB3FA.7010301@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here is a series of patches for ia64 vector domain. By these patches, we can
use more than NR_VECTORS(256) irqs. This is based on existing x86-64 vector
domain code. I tested it on my ia64 box.

Changes from previous patchset:

- rebase to 2.6.22

- remove unnecessary whitespaces

- do the build test for all configs under arch/ia64/configs/

- define NR_IRQS as follow:

  Vector domain can provide the number of irqs being proportional to the
  number of CPUs theoretically. However, the relation between them is
  actually not linear, especially in large system. To avoid the memory
  consumption derived from too many irqs, I define NR_IRQS as follows:

  #if (NR_VECTORS + 32 * NR_CPUS) < 1024
  #define NR_IRQS (NR_VECTORS + 32 * NR_CPUS)
  #else
  #define NR_IRQS 1024
  #endif

- change initial value of vector_irq to IA64_SPURIOUS_INT_VECTOR. It is
  pointed by Tony.

  http://www.gelato.unsw.edu.au/archives/linux-ia64/0707/20673.html

  I marged it into [PATCH take3 8/12]

- add the description of vector domain in Documentation/kernel-parameters.txt

There are 12 patches for ia64 vector domain:

  [PATCH take3 1/12]  Remove block structure for locking in iosapic.c
  [PATCH take3 2/12]  Remove duplicated members in iosapic_rte_info
  [PATCH take3 3/12]  Cleanup lock order in iosapic_register_intr
  [PATCH take3 4/12]  Use per iosapic lock for indirect iosapic register access
  [PATCH take3 5/12]  Use dynamic irq for iosapic interrupts
  [PATCH take3 6/12]  Fix invalid irq vector assumption for iosapic
  [PATCH take3 7/12]  Check if irq is sharable
  [PATCH take3 8/12]  Add mapping table between irq and vector
  [PATCH take3 9/12]  Add support for vector domain
  [PATCH take3 10/12] Support irq migration across domain
  [PATCH take3 11/12] Enable percpu vector domain for IA64_GENERIC
  [PATCH take3 12/12] Enable percpu vector domain for IA64_DIG

For more details, please refer to the header of each patch.

Any comments or questions are welcome.

Thanks.
Yasuaki Ishimatsu
