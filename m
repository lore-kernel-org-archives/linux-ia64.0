From: Christoph Hellwig <hch@lst.de>
Date: Wed, 07 Aug 2019 13:30:20 +0000
Subject: RFC: remove sn2, hpsim and ia64 machvecs
Message-Id: <20190807133049.20893-1-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Tony,

let me know what you think of this series.  This drops the pretty much
dead sn2 and hpsim support, which then allows us to build a single ia64
kernel image that supports all remaining systems without extra indirections
in the fast path.

A git tree is also available at:

    git://git.infradead.org/users/hch/misc.git ia64-remove-machvecs

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/ia64-remove-machvecs
