From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Sun, 09 Feb 2003 07:58:06 +0000
Subject: Re: [Linux-ia64] sigaltstack and RBS
MIME-Version: 1
Content-Type: multipart/mixed; boundary="cWoXeonUoKmBZSoM"
Message-Id: <marc-linux-ia64-105590709805827@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805824@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805824@msgid-missing>
To: linux-ia64@vger.kernel.org

--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Here's a small test program.

Matt


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="test.c"

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/mman.h>
#include <asm/page.h>

#define RBS_BASE	(void *)0x60000fff80000000UL
#define RBS_SIZE	PAGE_SIZE

static void
mprotect_rbs(int flags)
{
	mprotect(RBS_BASE, RBS_SIZE, flags);
}

static void
SIGSEGV_handler(int sig, siginfo_t *info, void *uc)
{
#if 1
	abort();
#endif
	mprotect_rbs(PROT_READ|PROT_WRITE);
}

int
main(void)
{
	struct sigaction sa;
	stack_t newstack;
	static unsigned long stack[SIGSTKSZ/sizeof(unsigned long)] __attribute__((aligned(PAGE_SIZE))) /* paranoia */;

	newstack.ss_sp = stack;
	newstack.ss_flags = 0;
	newstack.ss_size = sizeof(stack);
	if (sigaltstack(&newstack, NULL) == -1)
	{
		perror("sigaltstack");
		return 1;
	}

	sigemptyset(&sa.sa_mask);
	sa.sa_flags = SA_ONSTACK | SA_SIGINFO;
	sa.sa_sigaction = SIGSEGV_handler;
	if (sigaction(SIGSEGV, &sa, NULL) == -1)
	{
		perror("sigaction");
		return 1;
	}

	mprotect_rbs(0);
	printf("Still alive!\n");
	return 0;
}

--cWoXeonUoKmBZSoM--

