From: Michael Madore <mmadore@turbolinux.com>
Date: Fri, 20 Apr 2001 16:46:06 +0000
Subject: [Linux-ia64] IA32 process segfaults on exit
Message-Id: <marc-linux-ia64-105590693005442@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

The attached 32 bit code will run without error on IA32, but the same binary
will generate the following errors when it returns on IA64.

sizeof(elf_gregset_t) (1024) != sizeof(struct pt_regs) (400)
Segmentation fault (core dumped)

Is this expected behavior?

-- 
Mike Madore
Software Engineer
TurboLinux, Inc.

