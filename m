From: Jes Sorensen <jes@wildopensource.com>
Date: Thu, 20 Jan 2005 09:03:19 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <yq0fz0wbhgo.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Wed, 19 Jan 2005 09:28:27 -0800, Jesse Barnes <jbarnes@sgi.com> said:
Jesse> So I guess we need to add ia64_set_page_wc() and
Jesse> ia64_set_page_uc() functions that set the appropriate page bits
Jesse> or return errors if the EFI memory map says a particular mode
Jesse> isn't allowed?  How does that sound to you, Tony & David?
Jesse> Fortunately there aren't that many users of pgprot_writecombine
Jesse> so fixing them up should be easy.

David> I'm still not clear which case you're concerned about: mapping
David> I/O memory with WC or mapping real memory with WC.  For the
David> latter, I think we may need an API to allocate memory that can
David> be mapped WC (if possible at all).

Hmmm,

What about real memory and mapping it uncached? Do we need to play the
same trick before allowing it to be mapped uncached? and for IO memory
mapped uncached?

Trying to map real memory uncached was what made me stumble upon the
PREFETCH_VISIBILITY limitation in the PAL code.

Cheers,
Jes
