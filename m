From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Feb 2004 21:47:40 +0000
Subject: Re: [patch] 2.6.3 sync unwind code with 2.4.25
Message-Id: <16442.29948.177970.936607@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4545.1077507994@kao2.melbourne.sgi.com>
In-Reply-To: <4545.1077507994@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 24 Feb 2004 08:38:16 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> On Mon, 23 Feb 2004 12:07:39 -0800,
  Keith> David Mosberger <davidm@napali.hpl.hp.com> wrote:
  >>>>>>> On Mon, 23 Feb 2004 14:46:34 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> The unwind code in 2.6.3 is missing a debug patch.  This
  Keith> patch is in 2.4.25 and makes it much easier to diagnose
  Keith> unwind problems.  printk output does not appear when
  Keith> in_interrupt(), kdb_printf output does.  This brings 2.6.3
  Keith> unwind closer to 2.4.25.

  >> Sorry, but I just don't see why there should be KDB-stuff in unwind.c
  >> when KDB isn't part of the official Linux tree.

  Keith> You took the same patch for unwind.c in the 2.4 kernel.

Well, that was 2.4.  I don't recall the details, but like I said, I
don't see a good reason for including KDB patches in the default
kernel when KDB isn't part of it.

	--david
