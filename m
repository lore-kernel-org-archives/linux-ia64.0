From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 22 May 2023 17:38:59 +0000
Subject: Re: [crosspost] dropping support for ia64
Message-Id: <2023052202-tuesday-ploy-9156@gregkh>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
In-Reply-To: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 22, 2023 at 05:27:23PM +0000, Luck, Tony wrote:
> >> As far as we have been able to establish, the only people that use
> >> this arch and code are people that would hate to see it go, but don't
> >> actually use it for anything other than checking whether it still
> >> boots, and don't have the skills or bandwidth to step up and maintain
> >> it upstream.
> >
> > Great, then let's drop it today, there is no need to wait until the end
> > of the year as nothing is going to change then.
> 
> I think this also puts the existing stable and LTS trees in some interesting
> state. After arch/ia64 is removed, there may be some tree-wide change
> that gets backported to stable & LTS. That may break arch/ia64 in those
> trees (e.g. because arguments to some common function are changed).
> 
> Maybe just deal with that if it happens ... and if anyone notices ... are there
> automated builds and boot test for ia64 in those trees?

Guenter builds for that, but really, if the tree breaks and no one
notices, is it really broken?  :)

We handle this all the time in other types of removals (drivers,
subsystems, etc.)  I doubt this tiny amount of arch code will matter
much in the long run.

thanks,

greg k-h
