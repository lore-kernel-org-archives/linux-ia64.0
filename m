From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 09 Oct 2003 01:53:46 +0000
Subject: Re: [PATCH] Fix IA64 build with separate source and build trees.
Message-Id: <marc-linux-ia64-106566459714625@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106565735409518@msgid-missing>
In-Reply-To: <marc-linux-ia64-106565735409518@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 9 Oct 2003 11:24:47 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Main advantage is it makes this bit of code almost identical
  Peter> between architectures, so that when someone updates it a
  Peter> simple grep will find it everywhere.  And yes, it should be
  Peter> ${ARCH} everywhere htat there's identical code between
  Peter> architectures (which means everywhere, for simplicity as to
  Peter> know when to use what)

I think we're going in circles.  Originally, I had $(ARCH) for similar
reasons as you state and then they got replaced by ia64 in the big
Makefile rewrite.  I don't really care much one way or the other, but
let's be consistent.  AFAIK, currently everybody is using the
architecture name, so we probably should stick to that.

	--david
