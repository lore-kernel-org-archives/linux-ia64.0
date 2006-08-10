From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Thu, 10 Aug 2006 12:48:04 +0000
Subject: Re: [PATCH] reformat ivt.S for 80-column use
Message-Id: <ed5aea430608100548r63259b05n4cd10dcac5f812b1@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155168978.12634.62.camel@deimos>
In-Reply-To: <1155168978.12634.62.camel@deimos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 10 Aug 2006 03:24:02 -0400, Jes Sorensen <jes@sgi.com> wrote:
> >>>>> "Al" = Al Stone <ahs3@fc.hp.com> writes:
>
> Al> So, my first patch for this list....please be gentle with me :).
> Al> I was having to read ivt.S quite a bit and the old formatting just
> Al> finally got to me; this patch rearranges comments so that
> Al> everything can be seen on an 80-column display, in line with Linux
> Al> coding style.  No instructions have been changed.  With any luck,
> Al> I didn't screw up any of the white space otherwise.
>
>
> Al> Signed-off-by: Al Stone <ahs3@fc.hp.com>
>
> Yay!
>
> Some of the really complex code is unnecessarily hard to follow due to
> this, so I give you my ack!

Huh?  Ever heard of the window resize button?  100 cols will be just
fine.  IA-64 assembly code is one area where it really helps to have
more than 80 cols.  Just my 2 cents, of course...

  --david
-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
