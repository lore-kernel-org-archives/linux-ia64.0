From: "Tian, Kevin" <kevin.tian@intel.com>
Date: Tue, 22 Nov 2005 04:44:25 +0000
Subject: RE: [Xen-devel] __ia64__ ifdef in xmalloc.c: "Fix ar.unat handling forfast paths"
Message-Id: <571ACEFD467F7749BC50E0A98C17CDD802C069CF@pdsmsx403>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Rusty Russell <rusty@rustcorp.com.au>, Xen Mailing List <xen-devel@lists.xensource.com>
Cc: Tony Breeds <tony@bakeyournoodle.com>, djm@kirby.fc.hp.com, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org

>From: Rusty Russell
>Sent: 2005=C4=EA11=D4=C221=C8=D5 12:53
>Hi all,
>
>	While browsing the code, I noticed this in xmalloc.c:
>
>#ifndef __ia64__
>    BUG_ON(align > SMP_CACHE_BYTES);
>#endif
>
>	This is clearly wrong: due to header alignment we cannot give you a
>greater alignment than SMP_CACHE_BYTES.  Overriding this will cause the
>allocation to succeed, but not give the alignment requested.  It usually
>indicates the caller should be fixed.
>
>Does someone with an ia64 box know why, or want to rip it out and see
>what breaks?
>
>Thanks!
>Rusty.
>--
>A bad analogy is like a leaky screwdriver -- Richard Braakman
>

I didn't note that ifdef before, and removing it doesn't break dom0. I doub=
t the reason from following definition which is copied from Linux directly =
into Xen:

#ifdef CONFIG_SMP
# define SMP_CACHE_SHIFT	L1_CACHE_SHIFT
# define SMP_CACHE_BYTES	L1_CACHE_BYTES
#else
  /*
   * The "aligned" directive can only _increase_ alignment, so this is
   * safe and provides an easy way to avoid wasting space on a
   * uni-processor:
   */
# define SMP_CACHE_SHIFT	3
# define SMP_CACHE_BYTES	(1 << 3)
#endif

For a UP system, SMP_CACHE_BYTES is only 8 bytes to save space. Then maybe =
several months ago, there's such requirement to xmalloc a 16bytes aligned (=
legal on ia64 system like a long double) structure and then failed due to B=
UG_ON with an immediate lazy hack to add ifdef there. For now, such case se=
ems disappearing after a quick test.

However I think the preferred way is to increase SMP_CACHE_SHIFT to 4 to ma=
tch maximum allowed alignment value. But I'm not sure from the comment abov=
e why "3" is defined there on native linux. CC to linux-ia64 list for stand=
ard answer. ;-)

Thanks,
Kevin
