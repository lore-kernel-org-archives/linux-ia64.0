From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 21 Mar 2000 23:12:35 +0000
Subject: Re: [Linux-ia64] gdb support for IA32?
Message-Id: <marc-linux-ia64-105590678204991@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204990@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204990@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Are there any plans to support gdb on IA32? 
	If so, when will it be available? 

I don't think that is the question you meant to ask.  gdb has had IA-32 (x86)
linux support for many years.

gdb support for IA-64 already exists and is already available.  The gdb support
is not complete yet, but most basic commands already work.

If you want a ia32-linux cross ia64-linux gdb, then that is a harder question,
as there is the issue of how to communicate between the ia32 and ia64 machines.
If you can use gdbserver, then that may still work.  It was used early in
gdb development before the native ia64 gdb was working well.  There are no
plans to maintain this long term though, as it ceased being interesting once
the native ia64 was working well enough to debug itself.

Jim


