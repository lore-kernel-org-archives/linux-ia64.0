From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 31 Aug 2000 22:29:34 +0000
Subject: Re: [Linux-ia64] new toolchain snapshots
Message-Id: <marc-linux-ia64-105590678205437@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205422@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205422@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 31 Aug 2000 15:19:10 -0700, Jim Wilson <wilson@cygnus.com> said:

  Jim> We can either live with the current set of warnings, or I can
  Jim> try to bring over patches from more recent FSF gcc sources to
  Jim> make them go away.

  >> OK, sounds good.

  Jim> What sounds good: living with it, or patching it away?

Either way, actually.  I don't care much which way it goes, though in
the short term the old behavior (no warning when a pointer to a type
other than void is passed) is better, as it avoids massive amounts of
warnings.

  >> PS: Yeah, I realize that I'm probably barking up the wrong
  >> tree.... ;-)

  Jim> You are welcome to send a complaint to gcc-bugs@gcc.gnu.org.

Will do.

	--david

