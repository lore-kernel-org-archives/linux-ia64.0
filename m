From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 19 Sep 2000 01:21:41 +0000
Subject: Re: [Linux-ia64] big endian code of NUE gcc
Message-Id: <marc-linux-ia64-105590678205501@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205500@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205500@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64-linux is little-endian.  The -mbig-endian option won't do anything useful
on an ia64-linux system.  You probably should have gotten a linker error
message though.  I think gcc needs to pass an option to the assembler so
that it can set the big-endian bit in the elf header.  Or else emit an
assembler directive to do this.

If you are emitting code for a different OS, and that OS has big-endian
support, and gcc has support for that OS, then -mbig-endian should do something
useful.  I do not know of any big-endian IA-64 targets at this time though,
so the big-endian support has never been tested.

Jim

