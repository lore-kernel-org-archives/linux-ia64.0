From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Fri, 21 Feb 2003 07:35:35 +0000
Subject: Re: [lia64-sim] Re: [Linux-ia64] ski and gcc-3.x
Message-Id: <marc-linux-ia64-105590709805898@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 20, 2003 at 11:23:22PM -0800, David Mosberger wrote:
> 
> I'm afraid you'll be out of luck without X: you _can_ run in
> batch-mode without X, but then you don't get the debugger.  If you
> want the debugger, there must be a way to create a simulated console
> and that's done by starting a slave xterm.  Without X, that's hard to
> do.  If I work remotely, I use ssh X forwarding to prevent this
> problem.

X forwarding is painful over a modem :)

To get around this, I wrote a small program that sits in place of xterm
(I put it first in my path with a wrapper script).  It relays to a pty
device; I then connect to the slave device with another program like
screen or minicom.

http://www.cse.unsw.edu.au/~matthewc/files/fake-xterm.c

Matt


