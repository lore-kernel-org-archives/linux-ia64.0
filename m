From: roneng@ca.ibm.com
Date: Mon, 10 Apr 2000 15:26:28 +0000
Subject: Re: [Linux-ia64] Tool chain ld program -Previous message
Message-Id: <marc-linux-ia64-105590678205012@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205003@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205003@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



The exact error I am getting is the following
usr/lib/gcc-lib/ia64-cygnus-linux/2.9-ia64-000216/crtbeginS.o(.fini_0x2):
relocation truncated to fit:  PCREL21B fini
collect2:  ld returned 1 exit status

Changing the max page size seems to solve this problem. But the error
message seems to indicate
that this might be a problem with the maximum size of shared library ld can
create. Other then changing the
max page size Is there a command line parameter of code change to ld that
will allow larger static library sizes?

Thanks,
Ronen Grosman
- e-mail roneng@ca.ibm.com



Jim Wilson <wilson@cygnus.com> on 04/06/2000 03:50:22 PM

Please respond to Jim Wilson <wilson@cygnus.com>

To:   Ronen Grosman/Toronto/IBM@IBMCA
cc:   linux-ia64@linuxia64.org
Subject:  Re: [Linux-ia64] Tool chain ld program -Previous message
      incomplete




     The link seems to be failing with Reallocation error.

That isn't enough info to be useful.  Also, I suspect that you got a
"reloc"
error not "Realloc" error.

     The changed.Cygnus file shows that this parameter was changed on
1999-11-06
     by cygnus from 0x10000000 to 0x10000,
     which was the original value was wondering if anyone knew why this
changed
     occurred, and if undoing the change is I did will
     cause any problems?

I don't recall exactly what it was.  I believe it had something to do with
how
physical and virtual addresses in an executable got allocated.  With the
smaller page size, I think we either got smaller executables (less padding)
or smaller load images (less wasted virtual address space).  Or maybe it
was
done because the resulting executables could be loaded more efficiently.
It
should be visible if you look at the resulting executable.

In any case, we aren't going to change it back unless we get some
explanation
of why the original value is better than the current value, so I need a
better explanation of what is going on, or a better bug report.

Jim





