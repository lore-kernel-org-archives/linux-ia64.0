From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 26 Apr 2004 21:46:01 +0000
Subject: RE: cacheble to uncachble change
Message-Id: <16525.33561.50405.815886@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <408D5C58.E07A5FBE@email.mot.com>
In-Reply-To: <408D5C58.E07A5FBE@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 26 Apr 2004 14:24:58 -0700, "Jim Hull" <jim.hull@hp.com> said:

  Jim> In addition to what David wrote, which I completely agree with,
  Jim> you also need to be aware that it is platform dependent whether
  Jim> any particular address range supports cacheable, uncacheable,
  Jim> or both attributes.  System firmware communicates to the OS
  Jim> which attributes are allowed for which address ranges.  I'm not
  Jim> familiar with how ia64-linux exposes this info within the
  Jim> kernel (maybe David could fill you in).

The EFI memory attributes for a particular physical address can be
looked up in ia64 linux via:

 unsigned long efi_mem_attributes (unsigned long phys_addr);

	--david
