From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 23 May 2003 01:50:54 +0000
Subject: Re: [Linux-ia64] offsets.h generation
Message-Id: <marc-linux-ia64-105590723705999@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705941@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705941@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 23 May 2003 11:09:14 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Anyway, here's hopefully the final patch, against the
  Peter> IA64-2.5 BK tree as of this morning.

Argh, bad timing: I just commited Rohit's patch for the streamlined
syscall path, which of course makes a number of changes to
print_offsets.c ;-(

I'd push it right now, except that I need to twists bk to let me do it
("bk undo" just never works quite as well as I'd like...).

	--david

