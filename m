From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 09 Feb 2001 19:42:09 +0000
Subject: Re: [Linux-ia64] TODO list
Message-Id: <marc-linux-ia64-105590693005129@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005124@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005124@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 09 Feb 2001 14:14:18 -0500, Jun Nakajima <jun@sco.com> said:

  Jun> Do we want to support epc-based system calls? I know some other
  Jun> IA-64 OS uses that mechanism. I'm not sure how much perfermance
  Jun> gain we can get by that in Linux, though.

That's certainly something I'm interested in investigating.  It's not
nearly as obvious a win as it may seem at first, so it's something that
needs to be looked at carefully.

In any case, this would be something for 2.5.x, so I don't think we
should clutter the current TODO list with such things (there are LOTS
of other performance related things we can do...).

	--david

