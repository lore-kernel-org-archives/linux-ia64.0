From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 29 Oct 2001 18:10:44 +0000
Subject: Re: [Linux-ia64] itc sync & clock_*
Message-Id: <marc-linux-ia64-105590698805407@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805400@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805400@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 29 Oct 2001, David Mosberger wrote:

> The first thing to do is to get this into the firmware.  Linux needs a
> way to detect when the ITCs are not driven off the same clock (i.e.,
> when there is a chance for the ITCs to drift).  There also needs to be
> a way for detecting when the clock frequencies are different, but I
> believe the info provided by PAL/SAL is sufficient (my only worry are
> rounding errors...).

Ok, we'll work on getting this pushed back, so at least the kernel can
figure out what to do.  Regarding glibc though: we really don't want to
have a different version just for our systems, so I'd like to come up with
a generic solution.  Maybe an ia64 specific clock driver that glibc could
map in to read synchronized clock info?  Is there a platform independent
way of doing this?  I'll poke around glibc some more to see if any of the
other arches deal with tis problem, but I'm sure there are people that are
already familiar with these sorts of issues that might be able to help
out.  Anyone?

Thanks a lot,
Jesse


