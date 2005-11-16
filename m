From: Robin Holt <holt@sgi.com>
Date: Wed, 16 Nov 2005 12:41:52 +0000
Subject: Re: [PATCH] RFC : Page table macros
Message-Id: <20051116124152.GB4573@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051116050037.GF2440@cse.unsw.EDU.AU>
In-Reply-To: <20051116050037.GF2440@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 15, 2005 at 10:09:46PM -0800, Chen, Kenneth W wrote:
> Ian Wienand wrote on Tuesday, November 15, 2005 9:01 PM
> > Please find below a patch to make some page table modifications
> > similar to something I posted earlier before the 4 level stuff.
> 
> I'm not so sure about the change in ivt.S.  It makes the code a
> lot harder to read.  After all, the asm code in ivt.S is very
> low level and deal with all the low level detail anyway.  You
> aren't going to get away with more macros.

I disagree.  I think we could make significant improvements in
readability.  I don't think this patch is there, but it at
least starts the ball rolling.

Ian, let me throw a different version back at you today which
will hopefully clear up what I am thinking.

Thanks,
Robin
