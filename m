From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 30 Jan 2003 23:40:38 +0000
Subject: Re: [Linux-ia64] CMD649 driver in 2.5.5x
Message-Id: <marc-linux-ia64-105590709805782@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805780@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805780@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 30 Jan 2003 13:58:13 -0800, grundler@cup.hp.com (Grant Grundler) said:

  Grant> I'm pretty sure RH AS and 2.4.20 isn't seeing those kinds of problems.

Yes, 2.4.xx is definitely fine.

  Grant> It's been passing stress testing and such. I suspect the problem
  Grant> is someone is rewriting the IDE subsystem and maybe some changes
  Grant> are needed to adopt cmd649 for that.

No, the IDE subsystem is actually back to basically 2.4.xx with "some"
changes.  So it shouldn't be too bad.

  Grant> I'll take a whack at it if we can get 2.5.59 to boot/run from our
  Grant> CVS linux-2.5 (which is merged to 2.5.59).

OK, that would be great.  Thanks!

	--david

