From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Jun 2002 17:46:04 +0000
Subject: [Linux-ia64] Re: kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905723@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Jun 2002 19:30:48 +0200 (DFT), Xavier Bru  <Xavier.Bru@bull.net> said:

  Xavier> It seems that null pointers passed as argument to syscalls
  Xavier> by wrong user code now generate a Oops, and enter kdb if
  Xavier> enabled.

Good point.  The signal handler path needs to check whether the fault
occurred inside a code range with an associated exception handler and
report it as a user fault, if so.  We already do this for the
unaligned handler.

	--david

