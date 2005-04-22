From: Jason Baron <jbaron@redhat.com>
Date: Fri, 22 Apr 2005 19:35:44 +0000
Subject: gate page oops
Message-Id: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,

While working on the RHEL 4 kernel (based on 2.6.9), i encountered a BUG() 
in mm/memory.c:get_user_pages() at the line: BUG_ON(pte_none(*pte));

Seems like in_gate_area() returns true, but there is no pte to map the 
page. That is, the in_gate_area() covers a larger range than what is 
actually mapped. 

I'm not sure if this is a problem in 2.6.11, as i didn't get a chance to 
build and test a kernel based on 2.6.11. 

The patch below fixed the problem i was seeing by simply restricting 
in_gate_area(). Although as i look at this now it may be incorrect based 
on the HAVE_BUGGY_SERGEL #define. I'll fix that up if this patch makes 
sense to others...

thanks,

-Jason


--- linux/include/asm-ia64/page.h.bak	2005-04-22 12:30:29.000000000 -0400
+++ linux/include/asm-ia64/page.h	2005-04-22 13:50:26.000000000 -0400
@@ -195,4 +195,15 @@
 
 #define devmem_is_allowed(x) 1
 
+#define CONFIG_ARCH_GATE_AREA 1
+
+#ifdef __KERNEL__
+#ifndef __ASSEMBLY__
+struct task_struct;
+struct vm_area_struct *get_gate_vma(struct task_struct *tsk);
+int in_gate_area(struct task_struct *task, unsigned long addr);
+#endif
+#endif
+
+
 #endif /* _ASM_IA64_PAGE_H */
--- linux/arch/ia64/mm/init.c.bak	2005-04-22 12:33:15.000000000 -0400
+++ linux/arch/ia64/mm/init.c	2005-04-22 14:43:02.000000000 -0400
@@ -691,3 +691,26 @@
 	ia32_mem_init();
 #endif
 }
+
+static struct vm_area_struct gate_vma = {
+        .vm_mm = NULL,
+        .vm_start = FIXADDR_USER_START,
+        .vm_end = FIXADDR_USER_END,
+        .vm_page_prot = PAGE_READONLY,
+        .vm_flags = 0
+};
+
+struct vm_area_struct *get_gate_vma(struct task_struct *tsk)
+{
+	return &gate_vma;
+}
+
+int in_gate_area(struct task_struct *task, unsigned long addr)
+{
+        if ((addr >= FIXADDR_USER_START) && (addr < FIXADDR_USER_START + PAGE_SIZE))
+                return 1;
+        if ((addr >= FIXADDR_USER_START + PERCPU_PAGE_SIZE) && (addr < FIXADDR_USER_START + PERCPU_PAGE_SIZE + PAGE_SIZE))
+                return 1;
+        return 0;
+}
+

#include <sys/ptrace.h>
#include <sys/types.h>
#include <unistd.h>


int main() {


	pid_t pid;
	int ret;
	long val;

	pid = fork();

	if (pid = 0) {
		//spin
		while(1);
	} else {
		ret = ptrace(PTRACE_ATTACH, pid, NULL, NULL);
		if(ret) {
			perror("attach error");
			exit(1);
		}

		val = ptrace(PTRACE_PEEKDATA, pid, 0xa000000000004000, 
NULL);
		printf("val is: %i\n", val);
	}	


}

