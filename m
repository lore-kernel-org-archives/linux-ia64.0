From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Tue, 20 Apr 2004 09:09:19 +0000
Subject: Dynamic System Calls & System Call Hijacking - demo syscall
Message-Id: <4084E8BF.2CEAE31F@nospam.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------8CCCCBBAB9EEE4142AA23BCE"
List-Id: <linux-ia64.vger.kernel.org>
References: <4084E85E.4722BFC6@nospam.org>
In-Reply-To: <4084E85E.4722BFC6@nospam.org>
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------8CCCCBBAB9EEE4142AA23BCE
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

 
--------------8CCCCBBAB9EEE4142AA23BCE
Content-Type: text/plain; charset=us-ascii;
 name="foo.c"
Content-Disposition: inline;
 filename="foo.c"
Content-Transfer-Encoding: 7bit

/*
 * Demo dynamic syscall
 */


#include <linux/module.h>
#include <asm/dyn_syscall.h>


const char name[] = "foo";


asmlinkage long
sys_foo(const int cmd, const caddr_t address, const size_t length,
					const int node, const pid_t pid)
{
	printk("\nsys_foo(%d, 0x%p, 0x%lx, %d, %d)\n",
					cmd, address, length, node, pid);
	return 0;
}


int syscall;


static int __init
init_foo(void)
{
	int	rc;

	printk("\nModule Foo\n");
	rc = dyn_syscall_reg(name, 0, (dyn_syscall_t) sys_foo);
	printk("dyn_syscall_reg() returned: %d\n", rc);
	if (rc < 0)
		return rc;
	syscall = rc;
	rc = syscall_unlock(name, syscall);
	if (rc < 0)
		panic("syscall_unlock() returned: %d\n", rc);
	return 0;
}


static void __exit
exit_foo(void)
{
	printk("\nModule Foo getting unloaded\n");
	int	rc;
	rc = prep_restore_syscall(name, syscall);
	if (rc < 0)
		panic("prep_restore_syscall() returned: %d\n", rc);
	while((rc = syscall_trylock(name, syscall)) == -EAGAIN){
		/*
		 * Having some blocking syscalls? Don't just busy wait,
		 * wake them up, sleep a bit in the mean time.
		 */
	}
	if (rc < 0)
		panic("syscall_trylock() returned: %d\n", rc);
	rc = dyn_syscall_unreg(name, syscall);
	if (rc < 0)
		panic("dyn_syscall_unreg() returned: %d\n", rc);
}


module_init(init_foo);
module_exit(exit_foo);


--------------8CCCCBBAB9EEE4142AA23BCE--

