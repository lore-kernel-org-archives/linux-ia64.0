From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 18:04:55 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <16878.41287.397332.789804@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Jan 2005 09:56:59 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> On Wednesday, January 19, 2005 9:53 am, David Mosberger
  Jesse> wrote:
  >> I'm still not clear which case you're concerned about: mapping
  >> I/O memory with WC or mapping real memory with WC.  For the
  >> latter, I think we may need an API to allocate memory that can be
  >> mapped WC (if possible at all).

  Jesse> Oh, I thought I said that in the first message, I'm talking
  Jesse> about I/O memory here.

OK, thanks for clarifying.

  Jesse> In any event though, we shouldn't be mapping anything with
  Jesse> the WC attribute that the EFI memory map doesn't allow.

Adding new routines for supporting this sounds reasonable, but I think
it needs to be added to linux/efi.h, since EFI isn't ia64-specific.

  Jesse> And yes, we probably do need a special allocator for mapping
  Jesse> regular memory with WC or UC attributes to avoid mapping the
  Jesse> same region with different attributes.

OK, sounds like we're in violent agreement.

	--david
