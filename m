From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 Feb 2003 16:08:59 +0000
Subject: Re: [lia64-sim] Re: [Linux-ia64] ski and gcc-3.x
Message-Id: <marc-linux-ia64-105590709805901@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805898@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805898@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 21 Feb 2003 18:35:35 +1100, Matt Chapman <matthewc@cse.unsw.edu.au> said:

  Matt> On Thu, Feb 20, 2003 at 11:23:22PM -0800, David Mosberger
  Matt> wrote:
  >>  I'm afraid you'll be out of luck without X: you _can_ run in
  >> batch-mode without X, but then you don't get the debugger.  If
  >> you want the debugger, there must be a way to create a simulated
  >> console and that's done by starting a slave xterm.  Without X,
  >> that's hard to do.  If I work remotely, I use ssh X forwarding to
  >> prevent this problem.

  Matt> X forwarding is painful over a modem :)

  Matt> To get around this, I wrote a small program that sits in place
  Matt> of xterm (I put it first in my path with a wrapper script).
  Matt> It relays to a pty device; I then connect to the slave device
  Matt> with another program like screen or minicom.

  Matt> http://www.cse.unsw.edu.au/~matthewc/files/fake-xterm.c

Heh, that's neat.

	--david

