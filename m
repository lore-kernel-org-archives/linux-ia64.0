From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 13 Nov 2007 22:07:45 +0000
Subject: Re: [patch 1/1] ia64: increase .data.patch offset
Message-Id: <87hcjper4e.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200711130855.lAD8tBWd002649@imap1.linux-foundation.org>
In-Reply-To: <200711130855.lAD8tBWd002649@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "akpm" = akpm  <akpm@linux-foundation.org> writes:

akpm> From: Andrew Morton <akpm@linux-foundation.org> I get this:

akpm> /opt/crosstool/gcc-3.4.5-glibc-2.3.6/ia64-unknown-linux-gnu/lib/gcc/ia64-unknown-linux-gnu/3.4.5/../../../../ia64-unknown-linux-gnu/bin/ld:
akpm> section .data.patch [a000000000000500 -> a000000000000507]
akpm> overlaps section .dynamic [a0000000000003c8 -> a000000000000507]

If you switch to gcc 4.1 the patch section shrinks again and this patch
isn't necessary.

(unfortunately there're bugs in gcc 4.2 that prevent compilation of
the tiger_defconfig, or I'd be using that).

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
