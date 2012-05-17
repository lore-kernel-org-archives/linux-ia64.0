From: Jonathan Nieder <jrnieder@gmail.com>
Date: Thu, 17 May 2012 22:49:55 +0000
Subject: Re: [PATCH 3.0.y, 3.2.y] ia64: Add accept4() syscall
Message-Id: <20120517224955.GD2967@burratino>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120516215700.GA10476@burratino>
In-Reply-To: <20120516215700.GA10476@burratino>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

Hi Émeric,

Émeric Maschino wrote:
> 2012/5/17 Ben Hutchings <ben@decadent.org.uk>:

>> Right, but this is not just for Debian.
>
> Uh? I thought that Debian was the latest Linux distribution to support IA-64.

Gentoo and Linux From Scratch include support for Itanium.  It is also
not too unusual to upgrade some components (especially the kernel) on
an older system when one wants newer features.

My original message was proposing to include this patch in the 3.0.y
and 3.2.y kernels available from kernel.org.  Ben made that change for
3.2.y so it will be included in 3.2.18 (unless some problem comes up
before then).  Sorry for the lack of context.

Ciao,
Jonathan
