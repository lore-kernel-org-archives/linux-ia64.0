From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 17 Jul 2003 17:42:23 +0000
Subject: Re: [PATCH] (2.4.21-bjorn-bk) Minimalist PAL mapping for SN2
Message-Id: <marc-linux-ia64-105846378209951@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105832171829546@msgid-missing>
In-Reply-To: <marc-linux-ia64-105832171829546@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 15 July 2003 8:14 pm, Christopher Wedgwood wrote:
> Altix/SN2 presently has the PAL located in a granule that has mixed
> cachability --- for this reason we need to map the PAL using the
> smallest mapping possible.

We had a big discussion inside HP a while back about a similar
issue (firmware reported a region that required run-time mapping
inside a granule that also contained a hole).  We pushed hard to
make everything inside a granule have the same attributes.

Given that you're stuck with this situation:

- I hate to clutter the generic efi.c with so much platform-
  specific stuff.  What are the implications of making this
  a platform vector?  I don't see any obvious dependencies that
  prevent us from doing machvec_init() earlier.

- As Tony mentioned, you might want to verify that there's nothing
  else in the granule that requires run-time mapping.

- If there are different cacheability attributes within a granule,
  efi_memmap_walk should remove the granule from efi_memmap.  Do
  you see that happening?  I guess since PAL is mapped with a TR,
  we probably can live without it being in the EFI memmap, but since
  we use the memmap to validate accesses to /dev/mem, the wrong
  thing will probably happen if you try to read the PAL space.

Bjorn

