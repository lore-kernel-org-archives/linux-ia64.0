From: Bill Nottingham <notting@redhat.com>
Date: Thu, 04 Dec 2003 21:56:20 +0000
Subject: can't boot 2.6.0-test11
Message-Id: <marc-linux-ia64-107057525104512@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Trying to boot a 2.6test ia64 kernel here, I'm getting:

Loadin vmlinux...Loading Linux... 
alloc.c(line 132):allocator: AllocatePages(2, 2, 3377699721561477, 0x40000000) failed (Not Found)
plain_loader.c(line 291):plain_elf64: AllocatePages(3377699721561477, 0x40000000) for kernel failed

Is the kernel just horribly misbuilt somehow, or is something else
going on?

Bill

