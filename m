From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 17 Nov 2003 23:40:25 +0000
Subject: Re: pages already locked on ia64
Message-Id: <marc-linux-ia64-106911257232380@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106881037208683@msgid-missing>
In-Reply-To: <marc-linux-ia64-106881037208683@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 14 Nov 2003 11:22:23 +0100, Christian Hinkelbein <hinkelbein@ti.uni-mannheim.de> said:

  Christian> Hi, i have the need to lock malloc'ed user mem between
  Christian> kernel calls.

  Christian> On ia32 i succesfully do a lock_page() on every page
  Christian> returned by get_user_pages(), lateron i do unlock_page().
  Christian> On ia64 sometimes (on ia32 seemingly never) the first
  Christian> page is already locked, just after malloc().  For a quick
  Christian> hack i check all pages before trying to lock them, so
  Christian> that i am later just unlocking the not previously locked
  Christian> ones.

Umh, what page-size did you use?

In any case, a minimal test-program that reproduces the problem would
probably help you get an answer much faster.

Thanks,

	--david
