From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Apr 2002 20:40:38 +0000
Subject: Re: [Linux-ia64] C++ doesn't like asm/atomic.h
Message-Id: <marc-linux-ia64-105590701905417@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905396@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905396@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 8 Apr 2002 12:33:40 -0700, Gary Hade <garyhade@us.ibm.com> said:

  Gary> David, did you mean to say "... in having glibc not provide
  Gary> ..."?

Nope.  My preference would be for glibc to provide such a header.
Though I see Uli's point about kernel changes.

  Gary> I notice that the *_module(2) man pages which
  Gary> advocate the use of #include <linux/module.h> are installed as
  Gary> part of the modutils package.  Is is possibly "modutils" that
  Gary> should provide the header file that avoids sucking in the
  Gary> possibly problematic kernel-only code.

That certainly would work for me.

	--david

