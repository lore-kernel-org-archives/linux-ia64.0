From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 22 Sep 2004 21:13:12 +0000
Subject: rename generic_defconfig to defconfig?
Message-Id: <200409221713.12673.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just thought I'd float the idea of making the ia64 defconfig into a generic 
ia64 kernel config.  It's probably easiest just to rename generic_defconfig 
to defconfig since that already works everywhere (well, except for akpm's box 
apparently).  That would make it extra easy to build a working kernel for the 
various ia64 boxes out there...

Jesse
