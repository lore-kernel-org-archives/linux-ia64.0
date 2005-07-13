From: david mosberger <dmosberger@gmail.com>
Date: Wed, 13 Jul 2005 03:28:24 +0000
Subject: Re: autocompilation hosed?
Message-Id: <ed5aea4305071220287a121e9@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea4305071214283aada0f2@mail.gmail.com>
In-Reply-To: <ed5aea4305071214283aada0f2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 7/12/05, Ian Wienand <ianw@gelato.unsw.edu.au> wrote:
> On Tue, Jul 12, 2005 at 03:28:35PM -0700, david mosberger wrote:
> > On 7/12/05, Ian Wienand <ianw@gelato.unsw.edu.au> wrote:
> > > Hopefully I'll fix it today or tomorrow (at least you can see it which
> > > means we must have DNS sorted out ... finally :)
> 
> Ok, some fiddling and a quick cogito update and it is running again.
> For future runs it should use gcc-4.0; do you think this is a good
> idea?

I'm also using gcc-4.0.1 by default now.  It basically seems to work
(apart from lots of additional annoying warning messages).  There is
one oddity: on my zx2000, it doesn't boot anymore without console=tty0
or console=ttyS0 arguments.  I'm not sure yet whether that's a
compiler-triggered problem or whether something changed in the kernel
that's causing this.

  --david
