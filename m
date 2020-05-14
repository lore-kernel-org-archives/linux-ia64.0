From: Christian Brauner <christian.brauner@ubuntu.com>
Date: Thu, 14 May 2020 10:39:47 +0000
Subject: Re: [PATCH] ia64: enable HAVE_COPY_THREAD_TLS, switch to kernel_clone_args
Message-Id: <20200514103947.w4segr3rvwy4mjnh@wittgenstein>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200514074606.vkc35syhdep23rzh@wittgenstein>
 <6b298416-1e64-eee7-0bb4-3b1f7f67adc6@physik.fu-berlin.de>
 <d6c94d4f-a431-9de5-7a0f-661894dbec01@physik.fu-berlin.de>
 <20200514100459.pt7dxq2faghdds2c@wittgenstein>
 <2e22b0d2-b9ce-420d-48a0-0d9134108a5c@physik.fu-berlin.de>
 <20200514101540.25hvle74w63t66fs@wittgenstein>
 <20200514101914.fu7xhgaxtb5fy2ky@wittgenstein>
 <4aad9ad5-b0e9-12b0-0ad2-ac23fceae87b@physik.fu-berlin.de>
 <20200514103259.tdfjc5ds4igpmoxj@wittgenstein>
 <666503de-d8f9-b19c-6924-ab80d36cd446@physik.fu-berlin.de>
In-Reply-To: <666503de-d8f9-b19c-6924-ab80d36cd446@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Qais Yousef <qais.yousef@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, May 14, 2020 at 12:35:49PM +0200, John Paul Adrian Glaubitz wrote:
> On 5/14/20 12:32 PM, Christian Brauner wrote:
> > Do you have a very minimalistic ia64 userspace preferably without systemd where
> > you could simply test. That should give us an idea whether things work:
> > 
> > #define _GNU_SOURCE
> > #include <sys/wait.h>
> > #include <sys/utsname.h>
> > #include <sched.h>
> > #include <string.h>
> > #include <stdio.h>
> > #include <stdlib.h>
> > #include <unistd.h>
> > #include <sys/mman.h>
> > 
> > #define STACK_SIZE (8 * 1024 * 1024) /* standard stack size for threads in glibc */
> > 
> > int main(int argc, char *argv[])
> > {
> > 	char *stack;
> >         pid_t pid;
> > 
> > 	stack = mmap(NULL, STACK_SIZE, PROT_READ | PROT_WRITE,
> > 		     MAP_PRIVATE | MAP_ANONYMOUS | MAP_STACK, -1, 0);
> > 	if (stack = MAP_FAILED)
> > 		exit(EXIT_FAILURE);
> > 
> >         /* 
> > 	 * Note that legacy clone() has different argument ordering on
> >          * different architectures so this won't work everywhere.
> >          */
> >         pid = syscall(189 /* __NR_clone2 */, SIGCHLD, stack, STACK_SIZE, NULL, NULL);
> >         if (pid < 0)
> >                 exit(EXIT_FAILURE);
> >         if (pid = 0)
> >                 exit(EXIT_SUCCESS);
> >         if (wait(NULL) != pid)
> >                 exit(EXIT_FAILURE);
> > 
> >         exit(EXIT_SUCCESS);
> > }
> 
> root@titanium:~# gcc systemd_test.c -o systemd_test
> root@titanium:~# ./systemd_test
> root@titanium:~# echo $?
> 1
> root@titanium:~#
> 
> I can also give you access to this machine.

Yes please! :)
My ssh key should be on
https://launchpad.net/~cbrauner

Christian
