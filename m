From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 May 2003 20:29:36 +0000
Subject: RE: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705695@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 8 May 2003 10:54:05 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> In fact it might clear up the long standing issue with
  Tony> /proc/kcore, if we put the kernel at the low end of region 5
  Tony> all the assumptions that module addresses are higher than
  Tony> kernel addresses will be valid for ia64 too :-)

Yes, indeed.

  Tony> How does this look for an address map?

  Tony> 0xA000000000000000 kernel text
  Tony> 0xA000000100000000 kernel data
  Tony> 0xA000000200000000 percpu area
  Tony> 0xA000000300000000 vmalloc & kernel modules
  Tony> 0xBFFFFFFxxxxxxxxx CONFIG_VIRTUAL_MEM_MAP

  Tony> Reserving an almost arbitrary 4GB for each of kernel
  Tony> text/data/percpu (I picked 4GB, since it is the biggest page
  Tony> size supported by ia64 ... but other larger boundaries might
  Tony> make sense to make the upper level page tables for the vmalloc
  Tony> area start on a natural boundary).

I think we may want to reserve the first 4GB for miscellaneous stuff,
such as the start-of-kernel-space-hole, the gate page (and probably
soon a read-only page), and the percpu area.  In particular the
guaranteed-not-to-be-mapped page needs to be right at the end of user
space.

	--david

