From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 May 2003 18:42:51 +0000
Subject: Re: [Linux-ia64] Parallel make
Message-Id: <marc-linux-ia64-105590723705805@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705774@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705774@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 14 May 2003 19:48:46 +0200, Sam Ravnborg <sam@ravnborg.org> said:

  Sam> On Wed, May 14, 2003 at 01:38:23PM +1000, Ian Wienand wrote:
  >> When I try a parallel make, make seems to get it's dependencies
  >> out of order.

  Sam> Could you try the following patch.

  Sam> It does: 1) Remove superflous all: target, covered by the main
  Sam> Makefile 2) .PHONY shall only list non-file targets 3) Use make
  Sam> $@, $< where appropriate 4) For the offset file do not
  Sam> duplicate dependencies from main Makefile

Very nice.  Seems to do the trick for me.

	--david

