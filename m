From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 18 Apr 2003 15:03:16 +0000
Subject: Re: [Linux-ia64] Missing 2.4 changesets in bk http interface
Message-Id: <marc-linux-ia64-105590723705564@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705559@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705559@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 17 April 2003 8:49 pm, Keith Owens wrote:
> http://lia64.bkbits.net:8080/linux-ia64-2.4 says
> 
> 1 Changesets in the last four weeks
> 233 Changesets in the last eight weeks
> 
> Selecting the first option shows nothing.  Selecting the second option
> shows nothing more recent than 5 weeks ago.

I've also noticed the mismatch between the summary on that
page and the pages they link to.  The whole web interface is
done automagically by BitKeeper, though, so I don't think I
can do anything to fix it.

But you're probably looking at those changelogs because of
all the mail I've sent about merging patches in the last day
or two, and I *can* explain why they don't show up at
lia64.bkbits.net yet.  I've put the patches in my local BK
tree, but I haven't "pushed" them to the bkbits tree yet.
I hope to do that today, after I make sure everything builds
and boots.

Bjorn


