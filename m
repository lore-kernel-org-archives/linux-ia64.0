From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 May 2003 19:10:07 +0000
Subject: [Linux-ia64] Re: [PATCH] Increase size of user stack
Message-Id: <marc-linux-ia64-105590723705734@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 12 May 2003 10:38:44 -0400, Martin Hicks <mort@wildopensource.com> said:

  Martin> The user stack size is configurable through setrlimit().
  Martin> The default size of the user stack is 8MB and the max is
  Martin> ~0UL.  The problem is the addreses that are chosen for the
  Martin> stack (which grows down) and the register backing store
  Martin> (which grows up) are only 2GB apart.  My patch simply makes
  Martin> this space 512GB so that large stack are possible, without
  Martin> the stack smashing into the RBS.

OK, time for a pop-quiz:

 Q: You are faced with a timebomb that's set to go of in 1 minute.
    What do you do?

    (a) Tweak the timer so it goes off in ~4 1/4 hours instead and get
	the hell out of town.

    (b) Remove the timing device so it doesn't go off at all.

If you're answer is (a), I'm afraid you stand an excellent chance of
getting voted off the island.

Clear enough? ;-)

	--david

