From: Matthew Wilcox <willy@debian.org>
Date: Thu, 24 Jul 2003 12:55:50 +0000
Subject: Re: a nice way to reboot :-)
Message-Id: <marc-linux-ia64-105905135631924@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105887789030732@msgid-missing>
In-Reply-To: <marc-linux-ia64-105887789030732@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 24, 2003 at 02:30:51PM +0200, Bruno Cornec wrote:
> Well in general yes, but at least on i386 (I can't test on something else)
> doing cat /proc/kcore doesn't crash the system. And BTW why should it ?
> There is nothing wrong with it (for ex. I used it a lot of times to try
> to find a BIOS revision on i386).

you should be using gdb on /proc/kcore; nothing else.

> I just wonder if this could be used as a DOS from outside the system. In
> which case, it would be a Bad Thing (tm :-)

$ ls -l /proc/kcore 
-r--------    1 root     root     167776256 2003-07-24 08:46 /proc/kcore

and if they're root, you're already fucked.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
