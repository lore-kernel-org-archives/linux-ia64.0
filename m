From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 10 Oct 2001 22:27:42 +0000
Subject: Re: [Linux-ia64] Re: prctl patch for fpu faults
Message-Id: <marc-linux-ia64-105590698805323@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805302@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 10 Oct 2001 08:59:36 -0500 (CDT), Jack Steiner <steiner@sgi.com> said:

  Jack> There should be a way a site can change the default logging
  Jack> behavior & have it apply to ALL tasks..

I agree.  In theory, if you can change the behavior of "init", you'll
change the behavior of all subsequent tasks (the settings are
inherited across fork).  If you're willing to hack /etc/inittab, you
could probably do that with the "prctl" utility today (or perhaps even
with prctl + a suitable kernel command line), but none of these
solutions seem to be very pretty.  Perhaps someone can come up with a
cleaner solution?

	--david

