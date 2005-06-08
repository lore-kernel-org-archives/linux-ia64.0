From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 Jun 2005 17:23:43 +0000
Subject: RE: gate page oops
Message-Id: <17063.10655.936852.890638@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 8 Jun 2005 10:11:05 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  >> Unless there are any objections, please apply (for 2.6.12, hopefully).

  Tony> I still don't really understand why there are still any
  Tony> "PERCPU_PAGE_SIZE" references in this code.

  Tony> It looks like if we are building with a buggy linker, then we
  Tony> workaround problems by having two separate pages in our
  Tony> vmlinux image, and we map them at consecutive virtual pages
  Tony> (of size PAGE_SIZE) at the start of region 5 (GATE_ADDR   Tony> 0xa000000000000000).

  Tony> With a good linker, there is only one page in the vmlinux
  Tony> image, and we map it twice ... but for some unspecified reason
  Tony> we put the mappings on PERCPU_PAGE_SIZE boundaries at the
  Tony> start of region 5.  This leaves two holes (assuming
  Tony> PERCPU_PAGE_SIZE > PAGE_SIZE ... which it is unless
  Tony> PAGE_SIZEdk).

  Tony> Why do we need the holes?

Because ia64 linux ELF images can only alias at a 64KB boundary (the
max. supported kernel page size).

It doesn't make a huge difference and in fact I tried out a patch
which was just always using the BUGGY_SEGREL code.  That works too,
but it strikes me as less elegant (increases the size of the ELF image
needlessly; not that it makes a huge difference) and it's definitely
a larger patch (which affects several files).

  Tony> Should we also map zero pages in the buggy linker case (since
  Tony> there is a hole from GATE_ADDR + 2*PAGE_SIZE to
  Tony> FIXADDR_USER_END where there are no mappings).  Or perhaps
  Tony> FIXADDR_USER_END should only be GATE_ADDR + 2*PAGE_SIZE in the
  Tony> buggy linker case?

Good catch.  I think the latter (adjusting FIXADDR_USER_END) would be
better.

	--david
