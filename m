From: Bill Nottingham <notting@redhat.com>
Date: Fri, 08 Jun 2001 04:57:14 +0000
Subject: [Linux-ia64] sizeof(elf_gregset_t) (1024) != sizeof(struct pt_regs) (400)
Message-Id: <marc-linux-ia64-105590693005700@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is the above kernel warning bad?  I got it running some random old
ia32 binary (which coredumped)...

Bill

