From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Feb 2004 22:03:22 +0000
Subject: Re: [PATCH] linux-2.6.3_ia64-cyclone_A2.patch
Message-Id: <16435.57642.819103.775542@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1077136393.985.111.camel@cog.beaverton.ibm.com>
In-Reply-To: <1077136393.985.111.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 18 Feb 2004 13:52:03 -0800, john stultz <johnstul@us.ibm.com> said:

  John> Unfortunately there is no replicated clock on this hardware,
  John> so all nodes access the first counter on the first node. Not
  John> great, but correct and slow is better then fast and wrong.

OK, thanks for the info.  I'll try to keep this in mind should there
be timestamping questions again (as there was recently in the
scheduler).

>>>>> On Wed, 18 Feb 2004 13:49:44 -0800, john stultz <johnstul@us.ibm.com> said:

  John> Gah! Where is this trailing whitespace?

I already deleted the whitespace (my editor is showing it in bright
red, so it's kind a hard to ignore ;-).

  John> I went through this patch specifically eliminating any I could
  John> find. Perhaps my mail client is trying to irritate me.

The whitespace wasn't systematic, so i doubt it was the mailer.
Any chance the mail contained an old patch?

  John> The code, while similar, isn't quite shareable w/
  John> ia32. However, I'd be up for moving it to a separate IBM
  John> directory if you'd prefer, although for just a single file it
  John> seems like overkill.

I don't feel very strongly about it.  If you expect there to be other
IBM-platform specific files in the future, it would make sense to
create an ibm subdirectory.  It's really your call.

	--david
