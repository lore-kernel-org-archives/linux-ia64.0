From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 17 Jul 2004 00:06:10 +0000
Subject: Re: serious performance regression due to NX patch
Message-Id: <16632.28018.130890.290832@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407100528.i6A5SF8h020094@napali.hpl.hp.com>
	<Pine.LNX.4.58.0407110437310.26065@devserv.devel.redhat.com>
	<Pine.LNX.4.58.0407110536130.2248@devserv.devel.redhat.com>
	<Pine.LNX.4.58.0407110550340.4229@devserv.devel.redhat.com>
	<20040711123803.GD21264@devserv.devel.redhat.com>
	<Pine.LNX.4.58.0407121402160.2451@devserv.devel.redhat.com>
	<Pine.LNX.4.58.0407121315170.1764@ppc970.osdl.org>
	<16626.62318.880165.774044@napali.hpl.hp.com>
	<Pine.LNX.4.58.0407122358570.13111@devserv.devel.redhat.com>
	<1089734729.1356.79.camel@markh1.pdx.osdl.net>
In-Reply-To: <1089734729.1356.79.camel@markh1.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Haverkamp <markh@osdl.org>
Cc: Ingo Molnar <mingo@redhat.com>, davidm@hpl.hp.com, Linus Torvalds <torvalds@osdl.org>, Jakub Jelinek <jakub@redhat.com>, suresh.b.siddha@intel.com, jun.nakajima@intel.com, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>

>>>>> On Tue, 13 Jul 2004 09:05:29 -0700, Mark Haverkamp <markh@osdl.org> said:

  Mark> I think that there is  a problem with this piece of code in
  Mark> binfmt_elf.c:

  Mark> if (i = elf_ex.e_phnum)
  Mark>    def_flags |= VM_EXEC | VM_MAYEXEC;

I think there are other problems, too:

 - any fork() will reset mm->def_flags to zero so if you exec
   an old binary and it does a fork, future mmaps() won't
   have the execute-bit turned on any more; perhaps a rare problem,
   but it certainly seems an illogical behavior

 - likewise for do_mlockall(): it stomps on def_flags without preserving
   the old bits

Am I missing something?

	--david
