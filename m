From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sun, 09 Feb 2003 08:48:40 +0000
Subject: Re: [Linux-ia64] sigaltstack and RBS
Message-Id: <marc-linux-ia64-105590709805828@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805824@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805824@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 9 Feb 2003 18:58:06 +1100, Matt Chapman <matthewc@cse.unsw.edu.au> said:

  Matt> Here's a small test program.

Hmmh, the test program doesn't test backing-store _overflow_, it tests
what happens when you _remove_ a formerly valid mapping.  The program
fails because the "rfi" that gets executed when returning from
mprotect() may end up trying to restore registers that got spilled to
the backing store before the call mprotect(), the mprotect() then
removes access permission and hence the "rfi" can never finish
execution (effectively, the mprotect() makes the contents of the
spilled stacked registers disappear for good).

The current sigaltstack implementation isn't designed to handle such a
case.  And I'm not sure whether it should.  Is there a particular
reason you want to do this sort of thing?

	--david

