From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Jan 2005 22:16:58 +0000
Subject: RE: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <16888.5850.400198.271279@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Jan 2005 14:13:50 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  >> Tony, will you take the patches?  (Yes, there is still a question
  >> of how to cleanup/unify the MCA state allocation, but I think
  >> that's best done separately.)

  Tony> I've been playing with the patch on a few configurations
  Tony> (tiger with DIG and generic kernel still builds and boots SMP,
  Tony> my zx2000 is now running UP again) and haven't seen any
  Tony> regressions.  So yes, I'll apply your big patch and Russ's
  Tony> addendum.

Great!

  Tony> Jesse's generic up-build patch still needs some work, right?

Not if we change per_cpu_init() to _not_ allocate the MCA data.  I can
cook up a patch for doing this once the above two patches show up in
your release-2.6.11 bk tree.

	--david
