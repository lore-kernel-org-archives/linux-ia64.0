From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 31 Aug 2000 20:23:18 +0000
Subject: Re: [Linux-ia64] new toolchain snapshots
Message-Id: <marc-linux-ia64-105590678205434@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205422@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205422@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 31 Aug 2000 13:08:07 -0700, Jim Wilson <wilson@cygnus.com> said:

  Jim> 	I'm getting a lot of warnings for format %p with the new
  Jim> toolchain on kernel 2.4.0-test7, e.g.

  Jim> Before everyone goes and changes a lot of code, you should be
  Jim> aware that these warnings have since changed several times in
  Jim> the FSF gcc sources.  And will likely change again in the
  Jim> future.

  Jim> The current FSF gcc sources won't give a warning for void * or
  Jim> char * used with %p, and will accept other pointer types if you
  Jim> aren't using -pedantic.

  Jim> We can either live with the current set of warnings, or I can
  Jim> try to bring over patches from more recent FSF gcc sources to
  Jim> make them go away.

OK, sounds good.

I should say that this issue bothers me much less than those stupid
"format is not a string constant" messages.  The reason I hate those
messages is because this is the only place gcc gives a warning without
there being a way to get rid of it.  I don't think this warning should
be turned on for -Wall.

	--david

PS: Yeah, I realize that I'm probably barking up the wrong tree.... ;-)

