From: Horms <horms@verge.net.au>
Date: Fri, 25 Aug 2006 08:46:33 +0000
Subject: Re: [PATCH] 80-column reformatting for fsys.S
Message-Id: <20060825084633.B86553404A@koto.vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1156288081.7332.15.camel@fcboson.fc.hp.com>
In-Reply-To: <1156288081.7332.15.camel@fcboson.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 24 Aug 2006 18:15:29 +0000, Al Stone wrote:
> On Thu, 2006-08-24 at 09:09 -0700, Luck, Tony wrote:
>> > > Could you convert the C++ comments to C comments while you are at it?
>> >
>> > Good idea.  I'll try to make a second pass on the ones I've done,
>> > and make it a point to do it in the future.
>> 
>> I'm not so sure that this is such a great idea ... using C comments will
>> trim another 2 or three characters off the space you have available
>> on each line (depending on whether you like /*comment*/ or /* comment */)
>> so you will either need to be more terse in order to fit, or have more
>> comments run onto two lines, neither of which sound like an improvememt
>> to maintainability).
> 
> I'm not personally committed to either style of comment.  I agree
> that it could compress things in a bad way to use C-style.  And I'm
> not really that particular that they all need to be one style or the
> other (both seem to be used intermittently within the same file).
> I'll gladly bow to the majority, whichever it is.
> 
>> The 80-column rule has considerable merit (I like to have two code
>> windows side-by-side, and my employer has shown no signs of wanting
>> to shell out for a 24+" monitor for me :-( ... but I'm really not
>> so sure why people are so anti-c++ comments {BTW, I don't see this
>> prohibition in Documentation/CodingStyle ... is this just another
>> unwritten rule that everyone knows about?)
> 
> Heh.  Indeed.  As my eyes get older, the monitors seem to have to get
> larger :).  And hence the 80-column cleanup.
> 
> I couldn't find comment _style_ mentioned in CodingStyle either.  The
> only reason I know of for using C-style comments is to maintain some
> consistency with C; logically, that makes _some_ sense, but again, I
> personally don't care that much one way or the other.  I'm willing
> to go with whatever gets accepted as a patch :).

I don't really like them much myself, but that is beside the point.
I thought it was in the style guide, but if its not, I have no problem
with them staying there.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

