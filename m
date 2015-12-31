From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 31 Dec 2015 19:10:09 +0000
Subject: [PATCH v2 34/34] xen/io: use virt_xxx barriers
Message-Id: <1451572003-2440-35-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David

include/xen/interface/io/ring.h uses
full memory barriers to communicate with the other side.

For guests compiled with CONFIG_SMP, smp_wmb and smp_mb
would be sufficient, so mb() and wmb() here are only needed if
a non-SMP guest runs on an SMP host.

Switch to virt_xxx barriers which serve this exact purpose.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/xen/interface/io/ring.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/xen/interface/io/ring.h b/include/xen/interface/io/ring.h
index 7dc685b..21f4fbd 100644
--- a/include/xen/interface/io/ring.h
+++ b/include/xen/interface/io/ring.h
@@ -208,12 +208,12 @@ struct __name##_back_ring {						\
 
 
 #define RING_PUSH_REQUESTS(_r) do {					\
-    wmb(); /* back sees requests /before/ updated producer index */	\
+    virt_wmb(); /* back sees requests /before/ updated producer index */	\
     (_r)->sring->req_prod = (_r)->req_prod_pvt;				\
 } while (0)
 
 #define RING_PUSH_RESPONSES(_r) do {					\
-    wmb(); /* front sees responses /before/ updated producer index */	\
+    virt_wmb(); /* front sees responses /before/ updated producer index */	\
     (_r)->sring->rsp_prod = (_r)->rsp_prod_pvt;				\
 } while (0)
 
@@ -250,9 +250,9 @@ struct __name##_back_ring {						\
 #define RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(_r, _notify) do {		\
     RING_IDX __old = (_r)->sring->req_prod;				\
     RING_IDX __new = (_r)->req_prod_pvt;				\
-    wmb(); /* back sees requests /before/ updated producer index */	\
+    virt_wmb(); /* back sees requests /before/ updated producer index */	\
     (_r)->sring->req_prod = __new;					\
-    mb(); /* back sees new requests /before/ we check req_event */	\
+    virt_mb(); /* back sees new requests /before/ we check req_event */	\
     (_notify) = ((RING_IDX)(__new - (_r)->sring->req_event) <		\
 		 (RING_IDX)(__new - __old));				\
 } while (0)
@@ -260,9 +260,9 @@ struct __name##_back_ring {						\
 #define RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(_r, _notify) do {		\
     RING_IDX __old = (_r)->sring->rsp_prod;				\
     RING_IDX __new = (_r)->rsp_prod_pvt;				\
-    wmb(); /* front sees responses /before/ updated producer index */	\
+    virt_wmb(); /* front sees responses /before/ updated producer index */	\
     (_r)->sring->rsp_prod = __new;					\
-    mb(); /* front sees new responses /before/ we check rsp_event */	\
+    virt_mb(); /* front sees new responses /before/ we check rsp_event */	\
     (_notify) = ((RING_IDX)(__new - (_r)->sring->rsp_event) <		\
 		 (RING_IDX)(__new - __old));				\
 } while (0)
@@ -271,7 +271,7 @@ struct __name##_back_ring {						\
     (_work_to_do) = RING_HAS_UNCONSUMED_REQUESTS(_r);			\
     if (_work_to_do) break;						\
     (_r)->sring->req_event = (_r)->req_cons + 1;			\
-    mb();								\
+    virt_mb();								\
     (_work_to_do) = RING_HAS_UNCONSUMED_REQUESTS(_r);			\
 } while (0)
 
@@ -279,7 +279,7 @@ struct __name##_back_ring {						\
     (_work_to_do) = RING_HAS_UNCONSUMED_RESPONSES(_r);			\
     if (_work_to_do) break;						\
     (_r)->sring->rsp_event = (_r)->rsp_cons + 1;			\
-    mb();								\
+    virt_mb();								\
     (_work_to_do) = RING_HAS_UNCONSUMED_RESPONSES(_r);			\
 } while (0)
 
-- 
MST

