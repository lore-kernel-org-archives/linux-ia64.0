From: Roland McGrath <roland@redhat.com>
Date: Mon, 24 Feb 2003 21:20:57 +0000
Subject: [Linux-ia64] Re: strace improvement patch
Message-Id: <marc-linux-ia64-105590709805921@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805650@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805650@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I tried it and it works fine with 2.5.52.  Then I also tried on a
> 2.4.20 machine and sure enough, there it dies with a SIGSEGV.  I can
> look into it, but not tonight, so you may want to go ahead with the
> test-release.

Have you (or anyone) looked into strace -f on ia64 Linux 2.4.x yet?
This is still broken, and I haven't heard a peep from you in six weeks.
I really don't know ia64 well enough to be likely to have much luck myself.

It's not reasonable to release strace 4.5 with this still broken,
and I've run out of other reasons not to make the release already.

A little help?


Thanks,
Roland

