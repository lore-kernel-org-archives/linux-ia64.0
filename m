From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 05 Jan 2001 19:09:46 +0000
Subject: Re: [Linux-ia64] applying patch
Message-Id: <marc-linux-ia64-105590678205881@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Hiren,

The patches go on top of the corresponding tree from Linus.  For
example, linux-2.4.0-test12-ia64-001214.diff.bz2 goes on top of
Linus's linux-2.4.0-test12 tree.

On a related note: for those using the test12 tree, be sure to make
the following change after applying the IA-64 patch.  Without this
change, bad crashes can occur on systems with <2GB of RAM (it can
happen on systems with >=2GB of RAM too, but it's much less likely to
occur):

	Change line 330 in arch/ia64/lib/swiotlb.c from:

		set_bit(PG_arch_1, &virt_to_page(pg_addr));
	to
		struct page *page = virt_to_page(pg_addr);
		set_bit(PG_arch_1, &page->flags);

Hope this helps,

	--david

>>>>> On Thu, 28 Dec 2000 17:30:28 -0700, hiren_mehta@agilent.com said:

  Hiren> Hi All, I looked at the
  Hiren> http://www.kernel.org/pub/linux/kernel/ports/ia64/
  Hiren> directory. The directory has only one big .tar.gz file with
  Hiren> kernel sources and the rest of the files are patches. After I
  Hiren> looked at the directory, I got totally confused as there are
  Hiren> readme files which can tell me how to use the patches and
  Hiren> what should be the base kernel to apply the patch. Is it
  Hiren> that, the big tar.gz file should be the base kernel and then
  Hiren> I need to apply all the patches appearing in the directory or
  Hiren> that I need to apply only a specific patch ?

  Hiren> If there is any readmes or any other information regarding
  Hiren> the patches please send me the URL so that I can go through
  Hiren> that.

  Hiren> Thanks and regards, -hiren

  Hiren> _______________________________________________ Linux-IA64
  Hiren> mailing list Linux-IA64@linuxia64.org
  Hiren> http://lists.linuxia64.org/lists/listinfo/linux-ia64

