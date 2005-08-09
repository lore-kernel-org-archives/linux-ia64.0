From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Tue, 09 Aug 2005 20:45:31 +0000
Subject: Re: purpose of modular mca recovery
Message-Id: <200508092045.j79KjVwv1893089@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050809203915.GB28917@lst.de>
In-Reply-To: <20050809203915.GB28917@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Hellwig wrote:
> 
> is there any reason to built this code modular?  After all it would
> usually not be loaded when it was needed.  Not allowing modular mca
> recovery would help greatly because it's using some symbols that we'd
> prefer to unexport before chaning some implementation details
> (tasklist_lock and maybe force_sig)

It is extremely handy for testing to be able to insmod/rmmod 
mca_recovery to test changes, rather than having to reboot the 
kernel.  It is also a handly way to turn it on/off the recovery
code or upgrade without having to reboot.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
