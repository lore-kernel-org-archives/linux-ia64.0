From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 21 Mar 2007 22:16:17 +0000
Subject: [patch 0/5] ia64 memory attribute fixes
Message-Id: <200703211616.17257.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This series fixes a few memory mapping issues on ia64.  Outline:

  1  rename ioremap variables to match i386 (no functional change)
  2  use page table mappings in ioremap to avoid unsupported attributes
  3  allow WB mmap of /sys/.../legacy_mem
  4  fail mmaps that span areas with incompatible attributes
  5  update documentation & add tests

These are independent except that 2 depends on 1.
