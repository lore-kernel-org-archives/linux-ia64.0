From: "H. Peter Anvin" <hpa@zytor.com>
Date: Sun, 14 May 2006 22:02:21 +0000
Subject: Re: + git-hdrcleanup-vs-git-klibc-on-ia64.patch added to -mm tree
Message-Id: <4467A8ED.3090807@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1147632661.2551.5.camel@shinybook.infradead.org>
In-Reply-To: <1147632661.2551.5.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Hellwig wrote:
> 
> Using byte swizzling instrincts I supposed.  On the other hand asm/byteorder.h
> really shouldn't be user-exposed to start with.

asm/byteorder.h is at least useful for klibc; it can, of course, be 
completely done in klibc itself as long as bi-endian platforms have 
appropriate intrinsic defines.

klibc (ab)uses the __le16_to_cpu() et al macros; the reason for that is 
just to cut down on the amount of architecture-specific code that has to 
be written for klibc itself.

	-hpa

