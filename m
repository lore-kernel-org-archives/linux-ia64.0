From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 20 Feb 2002 22:26:35 +0000
Subject: Re: [Linux-ia64] null pointer dereference patch
Message-Id: <marc-linux-ia64-105590701905154@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806040@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806040@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 20 Feb 2002 11:22:29 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> On Tue, 12 Feb 2002 14:09:43 -0800, David Mosberger
  Keith> <davidm@hpl.hp.com> wrote:
  >>>>>>> On Tue, 12 Feb 2002 14:51:22 -0700, Bjorn Helgaas
  >>>>>>> <bjorn_helgaas@hp.com> said:
  >>
  Bjorn> Without the attached patch, unaligned references before
  Bjorn> init_modules() is called result in null pointer dereferences.
  Bjorn> This is against 2.4.17-ia64-011226.
  >>  I wonder whether module_list shouldn't be made to be NULL until
  >> init_modules() has had a chance to initialize it.  Keith?

  Keith> Some arch dependent init code relies on extable working right
  Keith> from the start, to catch kernel operations that may or may
  Keith> not be valid, depending on the precise hardware.  Changing
  Keith> module_list to NULL breaks that code, the patch is correct.

If you insist on the kernel module descriptor being initialized right
from the get go, then I'd argue there should be a way for statically
initializing this descriptor.  I really think it's a bad idea to have
partially initialized data laying around.

	--david

