From: barryn@pobox.com (Barry K. Nathan)
Date: Sat, 08 Dec 2001 00:12:40 +0000
Subject: [Linux-ia64] Re: Linux 2.4.17-pre6 drm-4.0
Message-Id: <marc-linux-ia64-105590698805659@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805654@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805654@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Linus ditched drm 4.0 months ago.  It only survives in arch add on
> patches like ia64 and in -ac trees.

No, it also survives as an add-on tarball for the standard kernel:
http://www.kernel.org/pub/linux/kernel/v2.4/drm-4.0.x.tar.bz2

Let me dig through my old mail so I can quote Linus on this... Here's
what he said in his Linux 2.4.8 announcement message (Subject
"Linux-2.4.8", sent on August 10th of this year):

> Ok, this one has various VM niceness tweaks that have made some people
> much happier. It also does a upgrade to the XFree86-4.1.x style DRM code,
> which means that people with XFree86-4.0.x can no longer use the built-in
> kernel DRM by default.
> 
> However, never fear. It's actually very easy to get the old DRM code too:
> if you used to use the standard kernel DRM and do not want to upgrade to a
> new XFree86 setup, just get the "drm-4.0.x" package from the same place
> you get the kernel from, and do
> 
>  - unpack the kernel
>  - cd linux/drivers/char
>  - unpack the "drm-4.0.x" package here
>  - mv drm new-drm
>  - mv drm-4.0.x drm
> 
> and you should be all set.

The impression I get (for 2.4) is that DRM 4.1 comes standard but you
should still be able to use 4.0 if you want, via that tarball.

-Barry K. Nathan <barryn@pobox.com>

