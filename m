From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Aug 2019 16:12:34 +0000
Subject: ioremap cleanups
Message-Id: <20190830161237.23033-1-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-m68k@lists.linux-m68k.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi all,

these are three cleanups from my generic ioremap series that needed
a few edits, and which I'd like you to pick up through your respective
arch trees for 5.4 if possible.
