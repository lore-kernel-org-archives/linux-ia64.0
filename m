From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 11 Mar 2004 07:56:03 +0000
Subject: Re: 2.6.3 Heisenbug in unwind.c
Message-Id: <16464.7059.383875.295183@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2654.1077624337@ocs3.ocs.com.au>
In-Reply-To: <2654.1077624337@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 10 Mar 2004 16:27:07 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> One possible contender for this unwind Heisenbug.  Building a
  Keith> 2.6.4-rc3 kernel with gcc version 3.2.3 20030502 (Red Hat
  Keith> Linux 3.2.3-24) and GNU ld version 2.14.90.0.4 20030523.  The
  Keith> unwind data in vmlinux is invalid, with overlapping entries.
  Keith> If this command reports anything at all then your unwind data
  Keith> is stuffed.

  Keith> readelf -u vmlinux | grep '+[a-f0-9]*>:' | head -5

  Keith> An extract of the descriptor triplets looks like this.  It
  Keith> seems that the unwind descriptors for .text and .init.text
  Keith> have been merged together, as if both sections started at the
  Keith> same offset.

  Keith> 00015a00 00015a70 005ced40
  Keith> 00015a80 00015b20 005ced58
  Keith> 00015ac0 00015d10 005c6828 Illegal insert, belongs to __init text
  Keith> 00015b20 00015ca0 005ced70
  Keith> 00015ca0 00015d30 005ced90
  Keith> 00015d20 00015e50 005c6848 Illegal insert, belongs to __init text
  Keith> 00015d40 00015f90 005ceda8
  Keith> 00015e60 00015f90 005c6868
  Keith> 00015fa0 000162e0 005c6888

How nasty!

I don't see this problem with:

	gcc version 3.3.3 20040125
	ld version 2.14.90.0.7 20031029 Debian GNU/Linux

I doubt it's a gcc bug.  Can you try with a more recent version
of binutils?

  Keith> Depending on precisely where the interrupt occurs, you may
  Keith> pick up a correct or an incorrect unwind descriptor.  Which
  Keith> in turn affects the backtrace, and explains why changing code
  Keith> size may the Heisenbug move.

Yeah, that would certainly explain it!  Good hunting!

	--david
