From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 Feb 2003 07:06:09 +0000
Subject: Re: [Linux-ia64] ski and gcc-3.x
Message-Id: <marc-linux-ia64-105590709805895@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805894@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805894@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Feb 2003 22:53:34 -0800, Randolph Chung <randolph@tausq.org> said:

  Randolph> hi, two questions really....

  Randolph> 1. is linux-2.5.x on ski supposed to work?

Yes, I use it all the time.  2.5.60 certainly works.

  Randolph> 2. is there a version of ski that works with gcc-3.2?

Yes.

  Randolph> the latest ski i can find (0.94311) doesn't work with
  Randolph> gcc-3.2 built kernels. On startup it gives: BFD: Dwarf
  Randolph> Error: Invalid or unhandled FORM value: 14.

That's only a warning though, right?  It should be harmless.

In any case: I currently have v0.9.81l1 of Ski in alpha testing and
beta testing should start next week.  If you can wait till then, that
would be easiest.  Otherwise, let me know and I'll see about sending
you the current test-binary.

	--david

