From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 05 Jun 2004 04:18:14 +0000
Subject: Re: [patch 2.6.6] Workaround linker bug
Message-Id: <16577.18822.988624.4464@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <9422.1085636381@kao2.melbourne.sgi.com>
In-Reply-To: <9422.1085636381@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 27 May 2004 15:39:41 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> Building 2.6.6-ia64-040521, using GNU ld version 2.14.90.0.4
  Keith> 20030523.  __gp is sometimes set incorrectly.  Instead of
  Keith> being .got + 0x2000000, it is set to .data + 0x2000000, which
  Keith> breaks some LTOFF22 and GPREL22 entries.

  Keith> This is non-deterministic, changing the path name to the
  Keith> kernel tree which changes the size of some messages in .data
  Keith> is enough to make the linker get it right.  Force __gp to be
  Keith> based on .got.

I can't say I have seen this myself, but the workaround is sensible enough,
so I applied the patch.

Thanks, and sorry for the delay (still working through my backlog...).

	--david
