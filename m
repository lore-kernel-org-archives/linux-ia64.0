From: Jes Sorensen <jes@sgi.com>
Date: Thu, 10 Aug 2006 12:52:08 +0000
Subject: Re: [PATCH] reformat ivt.S for 80-column use
Message-Id: <yq0lkpwu51j.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155168978.12634.62.camel@deimos>
In-Reply-To: <1155168978.12634.62.camel@deimos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger-Tang <David.Mosberger@acm.org> writes:

David> On 10 Aug 2006 03:24:02 -0400, Jes Sorensen <jes@sgi.com>
David> wrote:
>> Some of the really complex code is unnecessarily hard to follow due
>> to this, so I give you my ack!

David> Huh?  Ever heard of the window resize button?  100 cols will be
David> just fine.  IA-64 assembly code is one area where it really
David> helps to have more than 80 cols.  Just my 2 cents, of course...

It's all a matter of personal preference of course, but I don't like
resizing my windows depending on what files I am reading. Given that
CodingStyle calls for 80 columns I prefer to keep my windows at 80
columns (just as I try to stick to the glibc style when I write glibc
code, as much as I dislike it).

Cheers,
Jes
