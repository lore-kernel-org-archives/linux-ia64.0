From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 29 Jul 2003 21:31:58 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105951454815058@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 29 Jul 2003 14:15:20 -0700, Christopher Wedgwood <cw@sgi.com> said:

  Christopher> No --- because there are no other users...  the code
  Christopher> was almost certainly written a long time ago to solve
  Christopher> an SN specific purpose and has been carried around in
  Christopher> the form I presented.

  Christopher> I fully admit that in a general sense this code isn't
  Christopher> workable but I think perhaps the concept of some kind
  Christopher> of UC allocator might be.

I'm sorry, but that's _exactly_ the problem.  You are pushing an
SN2-specific hacks into the ia64 kernel and you seem to think that's
OK.  I don't want the ia64 kernel to turn into a collection of
vendor-specific hacks (whether from HP, Intel, SGI, or anyone else).
Yes, doing clean, general and efficient APIs is hard, requires
thinking, talking to others, etc., but it's the only way to get a
kernel that's maintainable.  If you only care about
efi_memmap_walk_uc() for SN2, that's fine by me, but in that case it
will stay in the SN2 tree.  If you want something in the normal ia64
kernel, please propose an API (and patch) that actually makes sense
beyond SN2.

	--david
