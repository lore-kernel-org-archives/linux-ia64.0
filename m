From: Dean Nelson <dcn@sgi.com>
Date: Tue, 22 Apr 2008 19:44:59 +0000
Subject: [Patch 0/4] prepare XPC and XPNET to support SGI UV -v4
Message-Id: <20080422194459.GB13086@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: jes@sgi.com, gregkh@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

This set of four patches moves XPC and XPNET to drivers/misc/sgi-xp in
preparation for enabling SGI UV X86_64 support.

This version is prompted by reported build problems with certain configs,
and a desire to keep things simple by only moving XPC/XPNET as is and
only addressing Lindent and checkpatch.pl issues (not x86_64 issues) at
this time.
