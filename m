From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 08 Jun 2001 16:02:35 +0000
Subject: Re: [Linux-ia64] sizeof(elf_gregset_t) (1024) != sizeof(struct pt_regs) (400)
Message-Id: <marc-linux-ia64-105590693005701@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005700@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005700@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 8 Jun 2001 00:57:14 -0400, Bill Nottingham <notting@redhat.com> said:

  Bill> Is the above kernel warning bad?  I got it running some random
  Bill> old ia32 binary (which coredumped)...

It shouldn't cause any problems beyond producing useless coredumps for
ia32.  In my opinion, it would be good to make ia32 coredumps work.
It shouldn't be that hard.

	--david

