From: Jack Steiner <steiner@sgi.com>
Date: Thu, 11 Aug 2005 17:24:57 +0000
Subject: [PATCH 0/7] - New SN hardware support - Overview
Message-Id: <20050811172454.GA13556@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following series of patches are required to support new
hardware that will be released by SGI. I've split the 
patches into small functionally related chunks. Apply the
patches in order. The kernel will build after each patch
is applied, but all patchs are required for a fully functional
kernel.

All files are in the arch/ia64/sn portion of the tree & should
have no effect on non-SN platforms.

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


