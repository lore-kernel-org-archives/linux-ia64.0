From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 29 Aug 2003 00:48:27 +0000
Subject: Re: shmat() ... is it a bug?
Message-Id: <marc-linux-ia64-106211849808996@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106211685507764@msgid-missing>
In-Reply-To: <marc-linux-ia64-106211685507764@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 28 Aug 2003 17:04:10 -0700, Umut Aymakoglu <umuta@us.ibm.com> said:

  Umut> Below ,I have 2 small programs which shows a problem in
  Umut> shmat() when the executable linked with the curses
  Umut> library(libncurses). Has anybody seen something like this?

  Umut> a.c --> allocates a shared memory segment and attaches.
  Umut> b.c --> attaching the allocated shared memory segment using the address
  Umut> from a.c

The bug is in the program: you can't assume that a fixed virtual
address is available for mapping.  When you link against -lncurses, it
happens to get loaded at the same address as "a" mapped the shared
memory segment.  Obviously, you can't have the shared memory segment
and libncurses mapped at the same address, hence the failure.

	--david
