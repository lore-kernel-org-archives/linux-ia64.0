From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Apr 2002 21:03:59 +0000
Subject: Re: [Linux-ia64] running X with 2.4.18 kernel
Message-Id: <marc-linux-ia64-105590701905499@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905497@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905497@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 23 Apr 2002 13:53:48 -0700, Chris McDermott <lcm@us.ibm.com> said:

  Chris> Anybody running X with a 2.4.18 (either 0226 or 0410 ia64
  Chris> patch) kernel?

Yes, I am.

  Chris> I discovered a couple of weeks ago that it
  Chris> didn't work, at least with the kernels I'm building. Now, I'm
  Chris> finally getting around to trying this again. The systems that
  Chris> fail are running RH 7.2 (with XFree86-4.1.0-8 or
  Chris> XFree86-4.1.0-15). I have also built and installed XFree86
  Chris> 4.2.0, same results. I'm just now starting to debug this, but
  Chris> thought I'd take the lazy way out first and see if anybody
  Chris> else has seen/solved this.

Search the earlier kernel patch announcements for chatr.  Then do:

	chatr -E /usr/X11R6/bin/XFree86

BTW: I did try to make the announcement as conspicuous as possible.  I
guess it still didn't work...

	--david

