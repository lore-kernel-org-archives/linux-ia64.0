From: Russ Anderson <rja@sgi.com>
Date: Wed, 30 Jul 2008 16:24:23 +0000
Subject: Re: Anyone tested 2.6.27-rc1?
Message-Id: <20080730162423.GB133571@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080730063731.GA31304@parisc-linux.org>
In-Reply-To: <20080730063731.GA31304@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

linux-next (2.6.27-rc1-next-20080730) builds and boots on Altix.


On Wed, Jul 30, 2008 at 12:37:31AM -0600, Matthew Wilcox wrote:
> 
> With zx1_defconfig on a dual-processor rx2600 prototype, I get:
> 
> VFS: Mounted root (ext3 filesystem) readonly.                                   
> Freeing unused kernel memory: 336kB freed                                       
> Mount failed for selinuxfs on /selinux:  No such file or directory              
> INIT: version 2.86 booting                                                      
> 
> ... and that's it.  I'm trying to do something else, so I'll probably
> just revert back to 2.6.26.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
