From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 25 Oct 2002 08:20:02 +0000
Subject: [Linux-ia64] ia64 2.5.44 make dep offsets.h not found
Message-Id: <marc-linux-ia64-105590709805245@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 24 Oct 2002 22:35:37 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>A quick patch that gets 2.5.44 (mostly) working on ia64 is now at
>ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/ in file:
>
>	linux-2.5.44-ia64-021024.diff.gz

If you start from a clean Linus 2.5.44 and apply the above patch then
include/asm-ia64/offsets.h does not exist.  All asm-*/offsets.h files
have been deleted from the base tarball, they are generated files.

make -f arch/ia64/tools/Makefile /build/kaos/2.5.44-ia64-021024/include/asm-ia64/offsets.h
/usr/bin/ia64-linux-gcc -g -O2 -Wall -D__KERNEL__ -Iinclude -DKBUILD_BASENAME=print_offsets_ -S arch/ia64/tools/print_offsets.c -o arch/ia64/tools/print_offsets.s
In file included from include/linux/thread_info.h:11,
                 from include/linux/spinlock.h:12,
                 from include/linux/capability.h:44,
                 from include/linux/sched.h:9,
                 from arch/ia64/tools/print_offsets.c:17:
include/asm/thread_info.h:8:25: asm/offsets.h: No such file or directory
include/asm/ptrace.h:56:25: asm/offsets.h: No such file or directory
include/asm/processor.h:87:25: asm/offsets.h: No such file or directory

Worse than that, not only does the code to calculate offsets.h need to
read offsets.h, it also needs the value of IA64_TASK_SIZE from
offsets.h so it can build offsets.h, an empty offsets.h will not do.
Quick and dirty workaround while I convert arch/ia64/makefile to
generate offsets.h using the standard method and remove this recursive
dependency (and get kdb for ia64 2.5.44 working).

Index: 44.3/arch/ia64/tools/Makefile
--- 44.3/arch/ia64/tools/Makefile Fri, 25 Oct 2002 17:08:41 +1000 kaos (linux-2.5/r/17_Makefile 1.2.1.5 444)
+++ 44.3(w)/arch/ia64/tools/Makefile Fri, 25 Oct 2002 18:14:38 +1000 kaos (linux-2.5/r/17_Makefile 1.2.1.5 444)
@@ -38,6 +38,7 @@ $(THIS)/offsets.h: $(THIS)/print_offsets
 comma	:= ,
 
 $(THIS)/print_offsets: $(THIS)/print_offsets.c FORCE
+	 [ ! -r $(TARGET) ] || echo "#define IA64_TASK_SIZE 0" > $(TARGET)
 	$(CC) $(CFLAGS) -DKBUILD_BASENAME=$(subst $(comma),_,$(subst -,_,$(*F))) \
 		$(THIS)/print_offsets.c -o $@
 
@@ -49,6 +50,7 @@ $(THIS)/offsets.h: $(THIS)/print_offsets
 	$(AWK) -f $(THIS)/print_offsets.awk $^ > $@
 
 $(THIS)/print_offsets.s: $(THIS)/print_offsets.c
+	 [ ! -r $(TARGET) ] || echo "#define IA64_TASK_SIZE 0" > $(TARGET)
 	$(CC) $(CFLAGS) -DKBUILD_BASENAME=$(subst $(comma),_,$(subst -,_,$(*F))) -S $^ -o $@
 
 endif


