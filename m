From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 11 Jul 2003 00:35:12 +0000
Subject: Re: clone testcases in LTP
MIME-Version: 1
Content-Type: multipart/mixed; boundary="8t9RHnE3ZwKMSgU+"
Message-Id: <marc-linux-ia64-105788373516732@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105778639326638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105778639326638@msgid-missing>
To: linux-ia64@vger.kernel.org


--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jul 09, 2003 at 03:17:42PM -0700, David Mosberger wrote:
>   Nathan> Could someone in the Linux ia64 community look at the clone
>   Nathan> system call tests that the LTP has under
> The only difference between clone() and clone2() is the explicit
> stack-size argument.

And that you pass the bottom of the stack, not the top?  Also, are
there explicit alignment requirements?  I thought it needed to be
aligned to page size (or maybe it was 16 bytes).  And should the stack
size be at a minimum ~8K, to allow enough room for register stack?

I have noticed a problem from the LTP tests.  Either I'm doing
something wrong (likely related to my assumptions above) or there is
something wrong.  See clone2.c below.  gdb doesn't catch the new
thread, but if you watch with strace you see the new thread gets a
SEGV somewhere in the dynamic loader on exit, and doesn't set the
return value properly.  The LTP tests pick this up.

This doesn't happen if thread() explicitly calls _exit(), rather than
just return (which should just call _exit).  This makes me think it's
something to do with __clone2 in in glibc.  It looks OK to me by
inspection, but unfortunately I am going away for some weeks today so
can't look into this much further.

Am I misunderstanding something?  Should my example work?

(I attached what I did anyway.  BTW the files have DOS line feeds,
which seems wrong)

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

--- clone2.c ---
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <sched.h>
#include <sys/wait.h>
#include <sys/types.h>
 
#define MB (1024*1024)
 
int thread(void *nothing)
{
        printf("HELLO\n");
        return 100;
}
 
int main(void)
{
 
    int ret, status;
 
    char *child_stack_base;
    child_stack_base = valloc( MB );
    printf("I see the stack @ %lx\n", child_stack_base);
 
    ret = __clone2(&thread, child_stack_base , MB, SIGCHLD);
 
    wait(&status);
    printf("Child exited (%d)\n", WEXITSTATUS(status));
     
    exit(0);
 
}
--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ltp-clone.patch"

Only in ltp-full-20030606-newgen/testcases/kernel/syscalls/clone/: .nfs0000000000c943670000009d
diff -u ltp-full-20030606/testcases/kernel/syscalls/clone/clone01.c ltp-full-20030606-newgen/testcases/kernel/syscalls/clone/clone01.c
--- ltp-full-20030606/testcases/kernel/syscalls/clone/clone01.c	2003-05-15 05:59:50.000000000 +1000
+++ ltp-full-20030606-newgen/testcases/kernel/syscalls/clone/clone01.c	2003-07-11 10:24:11.000000000 +1000
@@ -75,13 +75,23 @@
 #include "test.h"
 #include "usctest.h"
 
+#if defined (__ia64__)
+#define CHILD_STACK_SIZE 65536
+#else
 #define CHILD_STACK_SIZE 1024
+#endif
 
 #if defined (__s390__) || (__s390x__)
 #define clone __clone
 extern int __clone(int(void*),void*,int,void*);
 #endif
 
+#if defined (__ia64__)
+#define clone2 __clone2
+extern int  __clone2(int(void*),void*,size_t,int,void*);
+#endif
+
+
 static void setup();
 static void cleanup();
 static int do_child();
@@ -109,7 +119,7 @@
 	setup();
 
 	/* Allocate stack for child */
-	if((child_stack = (void *) malloc(CHILD_STACK_SIZE)) == NULL) {
+	if((child_stack = (void *) valloc(CHILD_STACK_SIZE)) == NULL) {
 		tst_brkm(TBROK, cleanup, "Cannot allocate stack for child");
 	}
 
@@ -124,6 +134,8 @@
 		 */
 #ifdef __hppa__
 		TEST(clone(do_child, child_stack, SIGCHLD, NULL));
+#elif defined (__ia64__)
+		TEST(clone2(do_child, child_stack, CHILD_STACK_SIZE, SIGCHLD, NULL));
 #else
 		TEST(clone(do_child, child_stack + CHILD_STACK_SIZE, SIGCHLD, NULL));
 #endif	
diff -u ltp-full-20030606/testcases/kernel/syscalls/clone/clone02.c ltp-full-20030606-newgen/testcases/kernel/syscalls/clone/clone02.c
--- ltp-full-20030606/testcases/kernel/syscalls/clone/clone02.c	2003-05-15 05:59:50.000000000 +1000
+++ ltp-full-20030606-newgen/testcases/kernel/syscalls/clone/clone02.c	2003-07-11 10:24:04.000000000 +1000
@@ -94,7 +94,12 @@
 #include "test.h"
 #include "usctest.h"
 
+#if defined (__ia64__)
+#define CHILD_STACK_SIZE 65536
+#else
 #define CHILD_STACK_SIZE 1024
+#endif
+
 #define FLAG_ALL CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND | SIGCHLD
 #define FLAG_NONE SIGCHLD
 #define PARENT_VALUE 1
@@ -107,6 +112,10 @@
 extern int __clone(int(void*),void*,int,void*);
 #endif
 
+#if defined (__ia64__)
+#define clone2 __clone2
+extern int  __clone2(int(void*),void*,size_t,int,void*);
+#endif
 
 static void setup();
 static int test_setup();
@@ -165,7 +174,7 @@
 	setup();
 
 	/* Allocate stack for child */
-	if((child_stack = (void *) malloc(CHILD_STACK_SIZE)) == NULL) {
+	if((child_stack = (void *) valloc(CHILD_STACK_SIZE)) == NULL) {
 		tst_brkm(TBROK, cleanup, "Cannot allocate stack for child");
 	}
 
@@ -188,6 +197,9 @@
 #ifdef __hppa__
 			TEST(clone(child_fn, child_stack,
 				   test_cases[i].flags, NULL));
+#elif (defined __ia64__)
+			TEST(clone2(child_fn, child_stack, 
+				    CHILD_STACK_SIZE, test_cases[i].flags, NULL));
 #else
 			TEST(clone(child_fn, child_stack + CHILD_STACK_SIZE,
 				   test_cases[i].flags, NULL));
@@ -217,6 +229,7 @@
 			 * parent function. If both functions returned
 			 * successfully, test passed, else failed
 			 */	
+			
 			if ((WIFEXITED(status)) && (WEXITSTATUS(status)) &&
 			    (test_cases[i].parent_fn())) {
 				tst_resm(TPASS, "Test Passed");
@@ -358,7 +371,6 @@
 
 	/* save child pid */
 	child_pid = getpid();
-
 	if (test_VM() && test_FILES() && test_FS() && test_SIG()) {
 		return 1;
 	}
diff -u ltp-full-20030606/testcases/kernel/syscalls/clone/clone03.c ltp-full-20030606-newgen/testcases/kernel/syscalls/clone/clone03.c
--- ltp-full-20030606/testcases/kernel/syscalls/clone/clone03.c	2003-05-15 05:59:50.000000000 +1000
+++ ltp-full-20030606-newgen/testcases/kernel/syscalls/clone/clone03.c	2003-07-11 10:23:52.000000000 +1000
@@ -72,13 +72,21 @@
 #include "test.h"
 #include "usctest.h"
 
+#if defined (__ia64__)
+#define CHILD_STACK_SIZE 65536
+#else
 #define CHILD_STACK_SIZE 1024
+#endif
 
 #if defined (__s390__) || (__s390x__)
 #define clone __clone
 extern int __clone(int(void*),void*,int,void*);
 #endif
 
+#if defined (__ia64__)
+#define clone2 __clone2
+extern int  __clone2(int(void*),void*,size_t,int,void*);
+#endif
 
 static void setup();
 static void cleanup();
@@ -109,7 +117,7 @@
 	setup();
 
 	/* Allocate stack for child */
-	if((child_stack = (void *) malloc(CHILD_STACK_SIZE)) == NULL) {
+	if((child_stack = (void *) valloc(CHILD_STACK_SIZE)) == NULL) {
 		tst_brkm(TBROK, cleanup, "Cannot allocate stack for child");
 	}
 
@@ -129,6 +137,8 @@
 		 */
 #ifdef __hppa__
 		TEST(clone(child_fn, child_stack, (int)NULL, NULL));
+#elif (defined __ia64__)
+		TEST(clone2(child_fn, child_stack, CHILD_STACK_SIZE, (int)NULL, NULL));
 #else
 		TEST(clone(child_fn, child_stack + CHILD_STACK_SIZE, (int)NULL, NULL));
 #endif
@@ -234,6 +244,7 @@
 	if ((close(pfd[1])) == -1) {
 		tst_resm(TWARN, "close(pfd[1]) failed");
 	}
+
 	return 1;
 }
 
diff -u ltp-full-20030606/testcases/kernel/syscalls/clone/clone04.c ltp-full-20030606-newgen/testcases/kernel/syscalls/clone/clone04.c
--- ltp-full-20030606/testcases/kernel/syscalls/clone/clone04.c	2003-05-15 05:59:50.000000000 +1000
+++ ltp-full-20030606-newgen/testcases/kernel/syscalls/clone/clone04.c	2003-07-11 10:23:38.000000000 +1000
@@ -73,13 +73,24 @@
 #include "test.h"
 #include "usctest.h"
 
+
+#if defined (__ia64__)
+#define CHILD_STACK_SIZE 65536
+#else
 #define CHILD_STACK_SIZE 1024
+#endif
 
 #if defined (__s390__) || (__s390x__)
 #define clone __clone
 extern int __clone(int(void*),void*,int,void*);
 #endif
 
+
+#if defined (__ia64__)
+#define clone2 __clone2
+extern int  __clone2(int(void*),void*,size_t,int,void*);
+#endif
+
 static void cleanup(void);
 static void setup(void);
 static int child_fn();
@@ -117,7 +128,7 @@
 	setup();			/* global setup */
 
 	/* Allocate stack for child */
-	child_stack = (void *) malloc(CHILD_STACK_SIZE);
+	child_stack = (void *) valloc(CHILD_STACK_SIZE);
 
 	/* The following loop checks looping state if -i option given */
 
@@ -132,7 +143,7 @@
 						 "child, skipping test case");
 					continue;
 				}
-#ifdef __hppa__				
+#if (defined  __hppa__) || (defined __ia64)
 				test_stack = child_stack;
 #else
 				test_stack = child_stack + CHILD_STACK_SIZE;
@@ -144,8 +155,13 @@
 			/*
 			 * call the system call with the TEST() macro
 		 	 */
+#ifdef __ia64__
+			TEST(clone2(test_cases[ind].child_fn, test_stack,
+				    CHILD_STACK_SIZE, (int)NULL, NULL));
+#else
 			TEST(clone(test_cases[ind].child_fn, test_stack,
-				   (int)NULL, NULL));
+				    CHILD_STACK_SIZE, (int)NULL, NULL));
+#endif
 	
 			if ((TEST_RETURN == -1) &&
 			    (TEST_ERRNO == test_cases[ind].exp_errno)) {
diff -u ltp-full-20030606/testcases/kernel/syscalls/clone/clone05.c ltp-full-20030606-newgen/testcases/kernel/syscalls/clone/clone05.c
--- ltp-full-20030606/testcases/kernel/syscalls/clone/clone05.c	2003-05-15 05:59:50.000000000 +1000
+++ ltp-full-20030606-newgen/testcases/kernel/syscalls/clone/clone05.c	2003-07-11 10:23:31.000000000 +1000
@@ -76,8 +76,18 @@
 extern int __clone(int(void*),void*,int,void*);
 #endif
 
+#if defined (__ia64__)
+#define clone2 __clone2
+extern int  __clone2(int(void*),void*,size_t,int,void*);
+#endif
 
+#if defined (__ia64__)
+#define CHILD_STACK_SIZE 65536
+#else
 #define CHILD_STACK_SIZE 1024
+#endif
+
+#define MAX_LINE_LENGTH 256
 #define FLAG CLONE_VM | CLONE_VFORK
 
 static void setup();
@@ -108,7 +118,7 @@
 	setup();
 
 	/* Allocate stack for child */
-	if((child_stack = (void *) malloc(CHILD_STACK_SIZE)) == NULL) {
+	if((child_stack = (void *) valloc(CHILD_STACK_SIZE)) == NULL) {
 		tst_brkm(TBROK, cleanup, "Cannot allocate stack for child");
 	}
 
@@ -123,6 +133,8 @@
 		 */
 #ifdef __hppa__
 		TEST(clone(child_fn, child_stack, FLAG, NULL));
+#elif (defined __ia64__)
+		TEST(clone2(child_fn, child_stack, CHILD_STACK_SIZE, FLAG, NULL));
 #else
 		TEST(clone(child_fn, child_stack + CHILD_STACK_SIZE, FLAG, NULL));
 #endif
diff -u ltp-full-20030606/testcases/kernel/syscalls/clone/clone06.c ltp-full-20030606-newgen/testcases/kernel/syscalls/clone/clone06.c
--- ltp-full-20030606/testcases/kernel/syscalls/clone/clone06.c	2003-05-15 05:59:50.000000000 +1000
+++ ltp-full-20030606-newgen/testcases/kernel/syscalls/clone/clone06.c	2003-07-11 10:23:19.000000000 +1000
@@ -82,8 +82,17 @@
 extern int __clone(int(void*),void*,int,void*);
 #endif
 
+#if defined (__ia64__)
+#define clone2 __clone2
+extern int  __clone2(int(void*),void*,size_t,int,void*);
+#endif
 
+#if defined (__ia64__)
+#define CHILD_STACK_SIZE 65536
+#else
 #define CHILD_STACK_SIZE 1024
+#endif
+
 #define MAX_LINE_LENGTH 256
 
 static void setup();
@@ -116,7 +125,7 @@
 	setup();
 
 	/* Allocate stack for child */
-	if((child_stack = (void *) malloc(CHILD_STACK_SIZE)) == NULL) {
+	if((child_stack = (void *) valloc(CHILD_STACK_SIZE)) == NULL) {
 		tst_brkm(TBROK, cleanup, "Cannot allocate stack for child");
 	}
 
@@ -136,6 +145,8 @@
 		 */
 #ifdef __hppa__
 		TEST(clone(child_environ, child_stack, (int)NULL, NULL));
+#elif (defined __ia64__)
+  		TEST(clone2(child_environ, child_stack, CHILD_STACK_SIZE, (int)NULL, NULL));
 #else
 		TEST(clone(child_environ, child_stack + CHILD_STACK_SIZE, (int)NULL, NULL));
 #endif
@@ -225,10 +236,11 @@
 	if ((close(pfd[0])) == -1) {
 		tst_brkm(TBROK, cleanup, "close(pfd[0]) failed");
 	}
-	
-	if ((sprintf(var, getenv("TERM"))) <= 0){
-		tst_resm(TWARN, "sprintf() failed");
+
+	if ( getenv("TERM") == NULL ) {
+		tst_resm(TWARN, "can't get TERM value");
 	}
+	strncpy(var, getenv("TERM"), sizeof(getenv("TERM")));
 
 	if ((write(pfd[1], var, MAX_LINE_LENGTH)) == -1) {
 		tst_resm(TWARN, "write to pipe failed");
@@ -238,7 +250,7 @@
 	if ((close(pfd[1])) == -1) {
 		tst_resm(TWARN, "close(pfd[1]) failed");
 	}
-	
+
 	return 0;
 }
 

--8t9RHnE3ZwKMSgU+--
