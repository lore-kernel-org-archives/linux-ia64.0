From: Jack Steiner <steiner@sgi.com>
Date: Tue, 01 Jun 2004 15:59:52 +0000
Subject: Re: [PATCH]  Reduce TLB flushing during process migration
Message-Id: <20040601155952.GA2491@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040522121159.GB19454@sgi.com>
In-Reply-To: <20040522121159.GB19454@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > 
> > But I don't understand why your patch adds two flush_tlb_mm() calls into
> > sched.c on ia32 where there previously was no such call.
> 
> I thought I had a good reason. Let me check & make sure I didnt overlook
> something. I'll get back to you.....
> 

You are right - the second call is not needed. I wanted to clear
cpu_vm_mask after an exec migration. That is not required because
exec calls init_new_context() shortly after the migrate anyway.



However, I found an unrelated issue.
It looks like the call to sched_balance_exec() from do_execve()
is in the wrong spot.


	int do_execve(char * filename,
        	char __user *__user *argv,
        	char __user *__user *envp,
        	struct pt_regs * regs)
	{
        	struct linux_binprm bprm;
        	struct file *file;
        	int retval;
        	int i;
	
        	sched_balance_exec();
	
        	file = open_exec(filename);
	
        	retval = PTR_ERR(file);
        	if (IS_ERR(file))
                	return retval;
	
        	bprm.p = PAGE_SIZE*MAX_ARG_PAGES-sizeof(void *);
		...



The code calls sched_balance_exec() before determining whether "filename"
actually exists. 

In many cases, users have several entries in $PATH.
If a full path name is not specified on the 'exec" call, the library 
code iterates thru the files in the PATH list until it finds the program. This
can result is numerous migrations of the parent process before
the program is actually found.


Shouldn't the call to sched_balance_exec() be moved to just before "bprm...."
or am I overlooking something?




--- linuxbase/fs/exec.c	2004-05-21 20:47:27.000000000 -0500
+++ linux/fs/exec.c	2004-06-01 10:46:35.000000000 -0500
@@ -1083,14 +1083,14 @@
 	int retval;
 	int i;
 
-	sched_balance_exec();
-
 	file = open_exec(filename);
 
 	retval = PTR_ERR(file);
 	if (IS_ERR(file))
 		return retval;
 
+	sched_balance_exec();
+
 	bprm.p = PAGE_SIZE*MAX_ARG_PAGES-sizeof(void *);
 	memset(bprm.page, 0, MAX_ARG_PAGES*sizeof(bprm.page[0]));
 



-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


