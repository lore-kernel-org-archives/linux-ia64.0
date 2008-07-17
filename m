From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 17 Jul 2008 05:55:30 +0000
Subject: Re: [PATCH 07/29] ia64/xen: add a neccessary header file to copmle include/xen/interface/xen.h
Message-Id: <20080717055530.GD25137%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1216260662692-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1216260662692-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 16, 2008 at 10:43:21PM -0700, Jeremy Fitzhardinge wrote:
> Isaku Yamahata wrote:
> >Create include/asm-ia64/pvclock-abi.h to compile which includes
> >include/asm-x86/pvclock-abi.h because ia64/xen uses same structure.
> >Hopefully include/asm-x86/pvclock-abi.h would be moved to somewhere
> >more generic.
> >  
> 
> Could you fix the patch title spelling ("necessary", "compile")?  The 
> misspelled words are hard to search for.
> 
> >Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
> >---
> > include/asm-ia64/pvclock-abi.h |    5 +++++
> > 1 files changed, 5 insertions(+), 0 deletions(-)
> > create mode 100644 include/asm-ia64/pvclock-abi.h
> >
> >diff --git a/include/asm-ia64/pvclock-abi.h 
> >b/include/asm-ia64/pvclock-abi.h
> >new file mode 100644
> >index 0000000..1c34d11
> >--- /dev/null
> >+++ b/include/asm-ia64/pvclock-abi.h
> >@@ -0,0 +1,5 @@
> >+/*
> >+ * use same streucute to x86's
> >  
> "structure"?
> 

Thanks for pointing out. Fixed typo.


From f6cfeafb4a63058b97a3a32f45e02ef878faa947 Mon Sep 17 00:00:00 2001
From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 4 Jul 2008 11:29:33 +0900
Subject: [PATCH 12/29] ia64/xen: add a necessary header file to compile include/xen/interface/xen.h

Create include/asm-ia64/pvclock-abi.h to compile which includes
include/asm-x86/pvclock-abi.h because ia64/xen uses same structure.
Hopefully include/asm-x86/pvclock-abi.h would be moved to somewhere
more generic.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/pvclock-abi.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/pvclock-abi.h

diff --git a/include/asm-ia64/pvclock-abi.h b/include/asm-ia64/pvclock-abi.h
new file mode 100644
index 0000000..63cbcca
--- /dev/null
+++ b/include/asm-ia64/pvclock-abi.h
@@ -0,0 +1,5 @@
+/*
+ * use same structure to x86's
+ * Hopefully asm-x86/pvclock-abi.h would be moved to somewhere more generic.
+ */
+#include <asm-x86/pvclock-abi.h>
-- 
1.5.3




-- 
yamahata
