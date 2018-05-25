From: Christoph Hellwig <hch@lst.de>
Date: Fri, 25 May 2018 14:35:05 +0000
Subject: refactor 32-bit dma limit quirks
Message-Id: <20180525143512.1466-1-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: x86@kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, netdev@vger.kernel.org

Hi all,

x86 currently has some quirks to force lower dma masks.  They are mostly
useful for certain VIA systems that otherwise corrupt data, but otherwise
don't make much sense given that the modern DMA APIs do the right thing
automatically.

This series dumps a few of these old kernel command lines (including their
not really working version on ia64), and moves the VIA quirk to a flag
in struct device so that it can be apply generically.  This will be needed
to support Xylinx root ports with a similar issue that show up in common
RISC-V boards.
