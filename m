From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 05 Jan 2001 20:29:13 +0000
Subject: Re: [Linux-ia64] Re: alignment issues on netif_rx (fwd)
Message-Id: <marc-linux-ia64-105590678205890@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes, that's a known problem.  Unalignment fault handling is REALLY
slow on IA-64 so it's not something you want to do in general.
However, the kernel certainly shouldn't crash due to an unaligned
network header either, so we need to enable unaligned handling in the
kernel (along with printing a nasty message ;-).

	--david

>>>>> On Mon, 18 Dec 2000 11:42:14 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> This just came up on the netdev list.  Is Andi correct and
  Keith> misaligned IP options will cause a kernel error?

  Keith> ------- Forwarded Message

  Keith> Return-Path: <owner-netdev@oss.sgi.com> Date: Sun, 17 Dec
  Keith> 2000 22:36:12 +0100 From: Andi Kleen <ak@muc.de> To: Johannes
  Keith> Erdfelt <johannes@erdfelt.com> Cc: "David S. Miller"
  Keith> <davem@redhat.com>, kai@thphy.uni-duesseldorf.de,
  Keith> netdev@oss.sgi.com Subject: Re: alignment issues on netif_rx

  Keith> On Sun, Dec 17, 2000 at 04:21:14PM +0100, Johannes Erdfelt
  Keith> wrote:
  >>  However, I can't imagine we've made it this long without this
  >> being a problem so there must be something I'm missing.

  Keith> Nobody apparently tried to use IPX on IA64 yet (due to a
  Keith> different ethernet header length it usually has to deal with
  Keith> an misaligned header)

  Keith> With this there are also plenty of ways to crash an IA64 box
  Keith> remotely, e.g. by putting misaligned timestamps into options.


  Keith> - -Andi


  Keith> ------- End of Forwarded Message



  Keith> _______________________________________________ Linux-IA64
  Keith> mailing list Linux-IA64@linuxia64.org
  Keith> http://lists.linuxia64.org/lists/listinfo/linux-ia64

