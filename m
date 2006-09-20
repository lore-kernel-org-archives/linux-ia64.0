From: Horms <horms@verge.net.au>
Date: Wed, 20 Sep 2006 02:42:59 +0000
Subject: Kexec/Kdump: kdump_disable_iosapic needs CONFIG_IOSAPIC
Message-Id: <20060920024544.420966000@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

kdump_disable_iosapic() doesn't exist without CONFIG_IOSAPIC,
calling it needs to be gaurded by a corresponding #ifdef

This patch has been updated for IA64 Kexec/Kdump patch for 2.6.18-rc6,
http://permalink.gmane.org/gmane.linux.ports.ia64/14988

Signed-Off-By: Simon Horman <horms@verge.net.au>

diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index ccc898c..b3f4915 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -121,7 +121,9 @@ machine_crash_shutdown(struct pt_regs *p
 	 * In practice this means shooting down the other cpus in
 	 * an SMP system.
 	 */
+#ifdef CONFIG_IOSAPIC
 	kexec_disable_iosapic();
+#endif
 #ifdef CONFIG_SMP
 	kdump_smp_send_stop();
 	if (kdump_wait_cpu_freeze() && kdump_on_init) 	{
@@ -135,7 +137,9 @@ static void 
 machine_kdump_on_init(void)
 {
 	local_irq_disable();
+#ifdef CONFIG_IOSAPIC
 	kexec_disable_iosapic();
+#endif
 	machine_kexec(ia64_kimage);
 }
 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

