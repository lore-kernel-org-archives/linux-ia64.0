From: Jim Wilson <wilson@specifixinc.com>
Date: Wed, 16 Jun 2004 21:57:00 +0000
Subject: Re: [PATCH] new ".serialize" gas directive
Message-Id: <1087423020.1178.36.camel@leaf.tuliptree.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16537.51724.854691.934006@napali.hpl.hp.com>
In-Reply-To: <16537.51724.854691.934006@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2004-06-15 at 18:54, Chris Wedgwood wrote:
> I was just looking over the nested fault handler this thread came to
> mind.
> There is exactly that situation with '.pred.rel "mutex", p6, p7' where
> gas should be able to infer this from the 'cmp.eq p6,p7 = 5,r17'
> preceding this and there are no intermediate labels.

I assume you are talking about the first one in arch/ia64/kernel/ivt.c.
Current gas seems to get this right without the .pred.rel.

I see that the LOAD_PHYSICAL macro expansion includes a tag, which is
kind of like a label.  Perhaps there was a problem with tags in earlier
gas versions, or perhaps earlier kernel versions used an actual label
instead of a tag here.  Use of a label here may have been necessary
before the assembler had tag support for instance, in which case the
.pred.rel would have been necessary.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

