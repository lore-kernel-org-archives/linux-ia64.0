From: Nathan Scott <nathans@sgi.com>
Date: Thu, 09 Oct 2003 03:15:01 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106566948017524@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 08, 2003 at 06:57:13PM -0700, David Mosberger wrote:
> >>>>> On Thu, 9 Oct 2003 11:25:58 +1000, Nathan Scott <nathans@sgi.com> said:
> 
>   Nathan> The problem is not the interfaces - they tend to use "long"
>   Nathan> directly and will be unaffected.  When I started running our
>   Nathan> tests with large inode numbers, for the most part everything
>   Nathan> just worked.
> 
> Argh, of course it's about interfaces.  We don't want to break
> something unknowingly because of this change.

Yes, I understand that.

> Saying that "for the
> most part everything just worked" isn't exactly reassuring!

You have misunderstood and/or I have not been clear enough.

"When I started running tests"... i.e. before I fixed this issue
in asm-ia64/posix_types.h ... "for the most part everything just
worked"... i.e. most stuff worked before, but not the thing I
fixed; but now it is fixed, and all our tests pass now, and I
know of no remaining issues.

I did not review every possible interface for use of ino_t, no.
I suppose that needs to be done, I don't have that kind of time
available just now.

cheers.

-- 
Nathan
