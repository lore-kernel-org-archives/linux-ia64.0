From: Michael Madore <mmadore@turbolinux.com>
Date: Fri, 20 Apr 2001 16:47:01 +0000
Subject: [Linux-ia64] Oops, here is the test program
MIME-Version: 1
Content-Type: multipart/mixed; boundary="wac7ysb48OaltWcw"
Message-Id: <marc-linux-ia64-105590693005443@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Haven't had my morning caffeine yet. ;-)

-- 
Mike Madore
Software Engineer
TurboLinux, Inc.

--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="test.c"

#include <stdio.h>
#include <string.h>
#include <sys/io.h>
#include <asm/vm86.h>

#ifdef USE_LIBC_VM86
#include <sys/vm86.h>
#endif

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>

#define REAL_MEM_BASE 	((void *)0x10000)
#define REAL_MEM_SIZE 	0x10000
#define REAL_MEM_BLOCKS 	0x100


struct mem_block
	{
	unsigned int size : 20;
	unsigned int free : 1;
	};


static struct
	{
	int ready;
	int count;
	struct mem_block blocks[REAL_MEM_BLOCKS];
	} mem_info = { 0 };

static int
real_mem_init(void)
	{
	void *m;
	int fd_zero;

	if (mem_info.ready)
		return 1;

	fd_zero = open("/dev/zero", O_RDONLY);
	if (fd_zero == -1)
		{
		perror("open /dev/zero");
		return 0;
		}

	m = mmap((void *)REAL_MEM_BASE, REAL_MEM_SIZE,
	 PROT_READ | PROT_WRITE | PROT_EXEC,
	 MAP_FIXED | MAP_PRIVATE, fd_zero, 0);

	if (m == (void *)-1)
		{
		perror("mmap /dev/zero");
		close(fd_zero);
		return 0;
		}

	mem_info.ready = 1;
	mem_info.count = 1;
	mem_info.blocks[0].size = REAL_MEM_SIZE;
	mem_info.blocks[0].free = 1;
        
	return 1;
	}


int main( void )
{
	real_mem_init();
	return 0;
}


--wac7ysb48OaltWcw--

