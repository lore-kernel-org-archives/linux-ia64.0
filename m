From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 17 Sep 2001 15:33:42 +0000
Subject: Re: [Linux-ia64] sigaltstack not working
Message-Id: <marc-linux-ia64-105590698805192@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805189@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805189@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 17 Sep 2001 17:27:01 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> It is derived from a test program in clisp 2.26 that
  Andreas> verifies that catching stack overflow works.  That test is
  Andreas> even worse, you can only kill it with SIGKILL.

OK, that makes sense.  I'll look into it asap.

On an unrelated note: I fixed the ia32 subsystem so it can run
realplay v8, mozilla v0.94 (including Flash plug-in), and OpenOffice
638, among others.  If someone has an urgent need for this, I can make
an interim patch availabe.  Otherwise, it will show up in 2.4.10
(which presumably will happen soon).

	--david

