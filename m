From: Jes Sorensen <jes@sgi.com>
Date: Thu, 10 Aug 2006 07:24:02 +0000
Subject: Re: [PATCH] reformat ivt.S for 80-column use
Message-Id: <yq0psf9t5nx.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155168978.12634.62.camel@deimos>
In-Reply-To: <1155168978.12634.62.camel@deimos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Al" = Al Stone <ahs3@fc.hp.com> writes:

Al> So, my first patch for this list....please be gentle with me :).
Al> I was having to read ivt.S quite a bit and the old formatting just
Al> finally got to me; this patch rearranges comments so that
Al> everything can be seen on an 80-column display, in line with Linux
Al> coding style.  No instructions have been changed.  With any luck,
Al> I didn't screw up any of the white space otherwise.


Al> Signed-off-by: Al Stone <ahs3@fc.hp.com>

Yay!

Some of the really complex code is unnecessarily hard to follow due to
this, so I give you my ack!

Acked-by: Jes Sorensen <jes@sgi.com>

Jes
