From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 20 Dec 2003 00:32:14 +0000
Subject: Re: [patch] 2.6.0 MCA TLB error recovery
Message-Id: <marc-linux-ia64-107188035326280@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107181047921141@msgid-missing>
In-Reply-To: <marc-linux-ia64-107181047921141@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 20 Dec 2003 11:26:12 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> David, please apply the first mca/salinfo patch to your tree
  Keith> (Forward port the recent changes to pal.h, sal.h, mca.h,
  Keith> salinfo.c and mca.c from 2.4.23-rc2 to 2.6.0-test9), then I
  Keith> will do a 2.6 version of the second patch over the top.

Whoops, too late.  I did see the preempt comments and figured you'll
fix that once it's in the tree.  Can you go from what's in the bk
trees now (give me a minute or two, I'm just pushing things to
to-linus-2.5 and linux-ia64-2.5 will be next).

	--david
