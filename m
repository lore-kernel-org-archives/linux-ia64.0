From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 16 Aug 2002 23:10:28 +0000
Subject: Re: [Linux-ia64] patching the syscall table via a module
Message-Id: <marc-linux-ia64-105590701905949@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905938@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905938@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 14 Aug 2002 09:31:45 -0400, chas williams <chas@cmf.nrl.navy.mil> said:

  chas> afs patches the syscall table when it loads as a module.
  chas> currently afs pags and pioctl are implemented this way.  while
  chas> this might change in the future, its not going to happen any
  chas> time soon.  i have run into a problem with this recently, and
  chas> noticed that sys_call_table is declared as .rodata.  my older
  chas> ia64 machines dont seem to enforce the read only, but the new
  chas> sn machine does!

  chas> is there a particular reason the sys_call_table needs to be
  chas> .rodata and not just .data?  could it be changed?  it seems
  chas> the ia64 port is the only port that does this.

I don't have a problem with changing that, but beware that recent Red
Hat kernels no longer export the sys_call_table symbol.  Personally, I
don't like this syscall-patching business either (for several
reasons).  While a bit rude, perhaps the Red Hat approach will force
those who care to find a better solution. ;-)

	--david

