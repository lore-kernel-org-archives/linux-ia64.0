From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 15 May 2003 16:46:04 +0000
Subject: Re: [Linux-ia64] Parallel make
Message-Id: <marc-linux-ia64-105590723705833@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705774@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705774@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Martin,

On Thu, May 15, 2003 at 09:59:29AM +1000, Martin Pool wrote:
> On 14 May 2003, David Mosberger <davidm@napali.hpl.hp.com> wrote:
> > 
> >   >> I see the same thing, but it's only for asm-ia64/offsets.h.  After
> >   >> that, parallel makes work just fine.  I tend to be able to live with
> >   >> such "minor" build issues for a loooong time, giving others ample
> >   >> chance to get impatient first... ;-)
> > 
> >   Eric> Don't wait, do it now:
> >   Eric> make prepare
> >   Eric> make -j4 compressed
> 
> (Advertorial): Now you've got make -j4, you should try ccache and
> distcc.  They make development on big trees enormously more
> enjoyable.  Andrew Morton and other kernel developers love them.
> 
>   http://distcc.samba.org/
>   http://ccache.samba.org/
> 
Yes, distcc is really nice. I have been using it for a month or so
for my kernel compiles using a cluster of Itanium 2 machines. What
I like is that it is really easy to setup. The danger with the
approach is that you can easily overload your local (master) host.
As for kernel compiles for 2.5, there are a lot of ld steps
which are still all done on the master node.  Besides that you
can really feel the speed difference. I need to take a look at ccache
now that you mention it.

Very cool. 

-- 
-Stephane

