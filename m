From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 Feb 2003 07:23:22 +0000
Subject: Re: [Linux-ia64] ski and gcc-3.x
Message-Id: <marc-linux-ia64-105590709805897@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805894@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805894@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Feb 2003 23:13:35 -0800, Randolph Chung <randolph@tausq.org> said:

  >> That's only a warning though, right?  It should be harmless.

  Randolph> no, ski segfaults right after that.

Hmmh, that's odd.  In any case, the new version should fix that.

  Randolph> * run Unable to create console window

  Randolph> (i'm running this remotely, so no X ...)

I'm afraid you'll be out of luck without X: you _can_ run in
batch-mode without X, but then you don't get the debugger.  If you
want the debugger, there must be a way to create a simulated console
and that's done by starting a slave xterm.  Without X, that's hard to
do.  If I work remotely, I use ssh X forwarding to prevent this
problem.

	--david

