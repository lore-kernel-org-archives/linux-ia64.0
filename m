From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 17:53:38 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <16878.40610.22793.349575@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Jan 2005 09:28:27 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> On Wednesday, January 12, 2005 10:51 am, Jim Hull wrote:
  >> I'm not really qualified to design the right linux interfaces,
  >> but to be IPF compliant, you need to change all such places to
  >> first consult the EFI memory map.  Whether you do this once at
  >> boot time, on every call, whether to fail an unsupported request
  >> or remap the attribute to something the platform can support
  >> (e.g., mapping WC to UC), is all up to you.

  Jesse> So I guess we need to add ia64_set_page_wc() and
  Jesse> ia64_set_page_uc() functions that set the appropriate page
  Jesse> bits or return errors if the EFI memory map says a particular
  Jesse> mode isn't allowed?  How does that sound to you, Tony &
  Jesse> David?  Fortunately there aren't that many users of
  Jesse> pgprot_writecombine so fixing them up should be easy.

I'm still not clear which case you're concerned about: mapping I/O
memory with WC or mapping real memory with WC.  For the latter, I
think we may need an API to allocate memory that can be mapped WC (if
possible at all).

	--david
