From: Christoph Hellwig <hch@lst.de>
Date: Tue, 09 Aug 2005 20:39:15 +0000
Subject: purpose of modular mca recovery
Message-Id: <20050809203915.GB28917@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

is there any reason to built this code modular?  After all it would
usually not be loaded when it was needed.  Not allowing modular mca
recovery would help greatly because it's using some symbols that we'd
prefer to unexport before chaning some implementation details
(tasklist_lock and maybe force_sig)
