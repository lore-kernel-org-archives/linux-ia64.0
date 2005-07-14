From: david mosberger <dmosberger@gmail.com>
Date: Thu, 14 Jul 2005 17:43:22 +0000
Subject: Re: autocompilation hosed?
Message-Id: <ed5aea4305071410437afb6db9@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea4305071214283aada0f2@mail.gmail.com>
In-Reply-To: <ed5aea4305071214283aada0f2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 7/14/05, Magenheimer, Dan (HP Labs Fort Collins)
<dan.magenheimer@hp.com> wrote:
> > > No ... I saw it too without gcc-4.  See
> > http://tinyurl.com/clzbu where I
> > > identified the patch that seems to be the cause.
> >
> > Patch below fixes the problem.  Moral of the story: don't add
> > "attributed(packed)" lightly!
> 
> IIRC as of gcc3.2, attribute(packed) on ia64 meant roughly the
> equivalent of specifying "generate the worst case possible
> code even for things that are aligned".  Is that still the
> case in gcc-4?

I'm not sure whether gcc-4 is doing a better job at identifying
structures which are aligned better than the worst-case (I'd be
curious to hear about that, if somebody plays with this or already
knows how it behaves).  Having said that, for EFI that's hardly an
issue since most of the code using those structures is executed only
once at boot-time, so performance isn't an issue (I suppose code-size
may be almost a bigger issue in that area).

  --david
