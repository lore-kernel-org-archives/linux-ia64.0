From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 30 Jul 2008 06:37:31 +0000
Subject: Anyone tested 2.6.27-rc1?
Message-Id: <20080730063731.GA31304@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


With zx1_defconfig on a dual-processor rx2600 prototype, I get:

VFS: Mounted root (ext3 filesystem) readonly.                                   
Freeing unused kernel memory: 336kB freed                                       
Mount failed for selinuxfs on /selinux:  No such file or directory              
INIT: version 2.86 booting                                                      

... and that's it.  I'm trying to do something else, so I'll probably
just revert back to 2.6.26.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
