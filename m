From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jan 2002 03:01:55 +0000
Subject: Re: [Linux-ia64] Re: Status on ioremap patch
Message-Id: <marc-linux-ia64-105590698805785@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805186@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805186@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 09 Jan 2002 21:01:13 +0100, Steffen Persvold <sp@scali.no> said:

  Steffen> So, what about this patch (posted earlier) David ? Have you
  Steffen> seen the comments from Keith ?

Keith's concerns are legitimate and to some degree apply even for
ia64.  On ia64, we need to be careful to avoid mapping the same
physical page with different memory attributes.  If more and more
drivers are starting to use write-combine mappings, we need to solve
this problem properly.  I don't have a solution off hand (I suspect
we'll have to keep track of which i/o regions are mapped how) and
don't have time to work on it now.  I'd recommend to maintain a
separate patch for now, until a proper solution is ready (which will
have to take non-ia64 platforms into consideration, of course).

	--david

PS: I apologize for not being as responsive yet as I'd like to be.
    I'm done with the book (well, 99.999% as my wife put it...) and
    ready to attack my backlog of kernel work (and other things, such
    as user-level unwind support).  I just had a spell of bad luck
    this week, which didn't help.  Hopefully, over the next one or two
    weeks, things will start to go back to normal.

