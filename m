From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 21 Oct 2004 17:34:17 +0000
Subject: Re: ia64 implementation of lib/iomap.c
Message-Id: <200410211134.17221.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16759.51459.598187.91726@napali.hpl.hp.com>
In-Reply-To: <16759.51459.598187.91726@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 21 October 2004 8:34 am, David Mosberger wrote:
> Is anybody already working on an ia64-version of lib/iomap.c?  If not:
> just be aware that as more drivers are starting to use the API, it
> becomes increasingly likely that drivers will start to misbehave.  At
> least I think that's the case because the default lib/iomap.c makes
> some rather arbitrary assumptions about where the I/O ports can live.

For example, tulip is now busted on sx1000 systems.  If you're
working on it, let me know, otherwise I'll poke at it :-)  I'd
like to get generic_defconfig and zx1_defconfig working again
on those boxes.
