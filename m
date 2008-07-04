From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 04 Jul 2008 02:41:09 +0000
Subject: Re: [PATCH] xen: compilation fix for ia64 support.
Message-Id: <20080704024109.GE17895%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080703070952.GB15683%yamahata@valinux.co.jp> <486D49C7.5070702@goop.org>
In-Reply-To: <486D49C7.5070702@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeremy Fitzhardinge <jeremy@goop.org>, "Luck, Tony" <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xensource.com, xen-ia64-devel@lists.xensource.com, linux-ia64@vger.kernel.org

On Thu, Jul 03, 2008 at 02:51:03PM -0700, Jeremy Fitzhardinge wrote:
> Isaku Yamahata wrote:
> >don't include asm/pvclock-abi.h directly, but asm/xen/pvclock-abi.h
> >At this moment linux ia64 won't accept asm/pvclock-abi.h because
> >there's no user of it.
> 
> Huh?  Is this a ia64 maintainer policy?  Aren't you about to start using it?

Ah sorry, that was only what I expected. I haven't asked the maintainer yet.
I'm asking now.


> > Instead make it include asm/xen/pvclock-abi.h
> >and create asm-x86/xen/pvclock-abi.h which includes asm-x86/pvclock-abi.h.
> >  
> 
> I'm not very keen on crufting up asm-x86/xen/ for the ia64 code.  
> Couldn't you have an asm-ia64/xen/pvclock-abi.h which includes 
> <asm-x86/pvclock-abi.h>?

I'm file with that. In fact I don't have strong opinion here
as long as the linux ia64 maintainer, Tony, is fine.

Tony, what do you think about the following patch?
- path
  asm-ia64/pvclock-abi.h versus asm-ia64/xen/pvclock-abi.h
- including asm-x86/pvclock-abi.h

From fa958c98713f193eeab2cbe9bab1676059b850a3 Mon Sep 17 00:00:00 2001
From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 4 Jul 2008 11:29:33 +0900
Subject: [PATCH] ia64/xen: add a neccessary header file to copmle include/xen/interface/xen.h

Create include/asm-ia64/pvclock-abi.h to compile which includes
include/asm-x86/pvclock-abi.h because ia64/xen uses same struture.
Hopefully include/asm-x86/pvclock-abi.h would be moved to somewhere
more generic.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/pvclock-abi.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/pvclock-abi.h

diff --git a/include/asm-ia64/pvclock-abi.h b/include/asm-ia64/pvclock-abi.h
new file mode 100644
index 0000000..1c34d11
--- /dev/null
+++ b/include/asm-ia64/pvclock-abi.h
@@ -0,0 +1,5 @@
+/*
+ * use same streucute to x86's
+ * Hopefully asm-x86/pvclock-abi.h would be moved to somewhere more generic.
+ */
+#include <asm-x86/pvclock-abi.h>
-- 
1.5.3


-- 
yamahata
