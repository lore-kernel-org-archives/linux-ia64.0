From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 13 Jan 2001 02:29:33 +0000
Subject: Re: [Linux-ia64] /proc/pid/mem and stack variables
Message-Id: <marc-linux-ia64-105590693005040@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005037@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005037@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 12 Jan 2001 13:45:10 -0500, Pete Wyckoff <pw@osc.edu> said:

  Pete> maciej@ccrl-nece.technopark.gmd.de said:
  >> I have recompiled the library on IA64 under 2.4.0-test12 and
  >> using version 2.9-ia64-000216-final. The library works OK except
  >> when the address it tries to access via /proc/pid/mem refers to
  >> variables allocated on stack (e.g. local arrays defined in
  >> functions).
  >> 
  >> This is a snippet of code used to access memory via
  >> /proc/pid/mem:
  >> 
  >> void mem_read (int fd, void *buf, void *addr, size_t len) {
  >> 
  >> if (lseek (fd, (off_t)addr, SEEK_SET) = (off_t)-1) perror
  >> ("lseek"); read (fd, buf, len);
  >> 
  >> lseek in this code fails (EINVAL) always when addr is address of
  >> a variable allocated on stack.

  Pete> Try removing the "offset >= 0" check in default_llseek in
  Pete> fs/read_write.c.  Stack pages seem to have the high bit set
  Pete> which is flummoxing that test.

  Pete> If you keep this "solution" you may want to write an llseek
  Pete> function for /proc/pid/mem so that the entire kernel doesn't
  Pete> suffer any unforseen consequences.

Yes, implementing llseek for fs/proc/base.c:proc_mem_operations is the
right solution.  /dev/kmem already has its own llseek (which treats
the offset as unsigned) but, for some reason, was left out of the
/proc/pid/mem support.

Don, can you add this to the TODO list so we won't forget about it?

Thanks,

	--david

