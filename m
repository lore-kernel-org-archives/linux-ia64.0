From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 25 Sep 2002 19:05:49 +0000
Subject: Re: [Linux-ia64] platform detection at run-time
Message-Id: <marc-linux-ia64-105590701906059@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906051@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906051@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 25 Sep 2002 13:57:38 -0500, Nathan Straz <nstraz@sgi.com> said:

  Nathan> What are the puzzle pieces of a "properly configured
  Nathan> machine?"  It's worked on all Redhat 7.2 based systems I've
  Nathan> run.

It's wrong if execve("/bin/uname") returns a different value than the
x86 uname() system call.  To ensure consistency, it is necessary to
install the x86 version of uname in /emul/ia32-linux/bin/.

I'd hope that stuff like this will eventually be spelled out in the
LSB documents.

	--david

