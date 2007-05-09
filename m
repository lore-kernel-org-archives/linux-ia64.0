From: Ishimatsu Yasuaki <isimatu.yasuaki@jp.fujitsu.com>
Date: Wed, 09 May 2007 07:51:00 +0000
Subject: [RFC][PATCH 0/12] Support vector domain on ia64
Message-Id: <46417D64.4070908@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here is a series of patches for vector domain. By these patches, we can use
more than 256 irqs. There are based on existing x86-64 vector domain code.
There are for 2.6.21 and I tested them on my ia64 box.

This patch set is just a draft, so there are following TBDs, I think.

  o How to create vector domain

    Per CPU, per node, or others?

  o How to migrate irq

    In migration, we don't handle the vector for the pending irqs. Probably
    we should manage it.

  o NR_IRQS size

    Because I define NR_IRQS as 4096, there is a huge array on generic
    kernel_stat area. I should determine appropriate size.

  o Relation between irq and gsi

    On x86_64, irq equals to gsi. It is one easy way to get a suitable irq
    number from gsi, However, when gsi is larger than the biggest irq, it
    doesn't work.

  o How to assign irq number

    If pci drivers are enabled/disabled devices dynamically, its irq number
    is changed to the different one. I want to avoid it.

The following fourteen patches are related to the vector domain for ia64.
This patch set applies against 2.6.21.

  [PATCH 1/12]  Remove block structure for locking in iosapic.c
  [PATCH 2/12]  Remove duplicated members in iosapic_rte_info
  [PATCH 3/12]  Use per iosapic lock for indirect iosapic register access
  [PATCH 4/12]  Cleanup lock order in iosapic_register_intr
  [PATCH 5/12]  Use dynamic irq for iosapic interrupts
  [PATCH 6/12]  Fix invalid irq vector assumption for iosapic
  [PATCH 7/12]  Check if irq is sharable
  [PATCH 8/12]  Add mapping table between irq and vector
  [PATCH 9/12]  Add support for vector domain
  [PATCH 10/12] Support irq migration across domain
  [PATCH 11/12] Enable percpu vector domain for IA64_GENERIC
  [PATCH 12/12] Enable percpu vector domain for IA64_DIG

For more details. please refer to the header of each patch.

Any comments or questions are welcome.

Thanks.
Yasuaki Ishimatsu




