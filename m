From: Micah Parrish <micah.parrish@hp.com>
Date: Sat, 11 Oct 2003 23:22:48 +0000
Subject: Re: user-space unaligned accesses
Message-Id: <marc-linux-ia64-106608687732639@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106562414203331@msgid-missing>
In-Reply-To: <marc-linux-ia64-106562414203331@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>The ia64 architecture does a tty_write
>on a userspace unaligned access. Not only is this extremenly annoying,
>it's also very broken since the tty may well be suspended etc etc.
>Doing a printk on such an access by default is very broken already,
>lets not make it worse


I too see no reason to do a tty_write here.  Most other error messages
of the same level (KERN_WARNING) do not do a tty_write, and syslogd can
be configured to write KERN_WARNING messages to the console or anywhere
else if you care.  Smells like old debug code, and looks messy to the
end user.

-micah.parrish@hp.com

