From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:19 +0000
Subject: [PATCH 04/50] xen: add missing definitions in include/xen/interface/vcpu.h which ia64/xen needs
Message-Id: <1204741145301-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/xen/interface/vcpu.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/xen/interface/vcpu.h b/include/xen/interface/vcpu.h
index b05d8a6..87e6f8a 100644
--- a/include/xen/interface/vcpu.h
+++ b/include/xen/interface/vcpu.h
@@ -85,6 +85,7 @@ struct vcpu_runstate_info {
 		 */
 		uint64_t time[4];
 };
+DEFINE_GUEST_HANDLE_STRUCT(vcpu_runstate_info);
 
 /* VCPU is currently running on a physical CPU. */
 #define RUNSTATE_running  0
@@ -119,6 +120,7 @@ struct vcpu_runstate_info {
 #define VCPUOP_register_runstate_memory_area 5
 struct vcpu_register_runstate_memory_area {
 		union {
+				GUEST_HANDLE(vcpu_runstate_info) h;
 				struct vcpu_runstate_info *v;
 				uint64_t p;
 		} addr;
@@ -134,6 +136,7 @@ struct vcpu_register_runstate_memory_area {
 struct vcpu_set_periodic_timer {
 		uint64_t period_ns;
 };
+DEFINE_GUEST_HANDLE_STRUCT(vcpu_set_periodic_timer);
 
 /*
  * Set or stop a VCPU's single-shot timer. Every VCPU has one single-shot
@@ -145,6 +148,7 @@ struct vcpu_set_singleshot_timer {
 		uint64_t timeout_abs_ns;
 		uint32_t flags;			   /* VCPU_SSHOTTMR_??? */
 };
+DEFINE_GUEST_HANDLE_STRUCT(vcpu_set_singleshot_timer);
 
 /* Flags to VCPUOP_set_singleshot_timer. */
  /* Require the timeout to be in the future (return -ETIME if it's passed). */
@@ -164,5 +168,6 @@ struct vcpu_register_vcpu_info {
     uint32_t offset; /* offset within page */
     uint32_t rsvd;   /* unused */
 };
+DEFINE_GUEST_HANDLE_STRUCT(vcpu_register_vcpu_info);
 
 #endif /* __XEN_PUBLIC_VCPU_H__ */
-- 
1.5.3

