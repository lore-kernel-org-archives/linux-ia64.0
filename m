From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 01 Aug 2002 06:26:13 +0000
Subject: Re: [Linux-ia64] [patch] Assign __gp to middle of short data sections
Message-Id: <marc-linux-ia64-105590701905873@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905870@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905870@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 01 Aug 2002 16:00:39 +1000, Keith Owens <kaos@ocs.com.au> said:

  >> . = ALIGN(16); __gp = . + 0x200000; /* gp must be 16-byte aligned
  >> for exc. table */

  Keith> I tried that, same error, it is definitely a size problem.
  Keith> With my build, _data + 0x200000 (where __gp used to be) is
  Keith> e0000000049b7490, got starts at e000000004ced170, a
  Keith> difference from gp of 0x335ce0 bytes.  imm22 can only do +/-
  Keith> 0x200000.

Please try with the latest 2.4.18 patch---__gp *is* defined after
.data, not before.

  >>  The addresses in the exception table are currently gp-relative
  >> (so they fit in 32 bits), with the least-significant four bits
  >> reserved to encode extra info (such as slot number).  If someone
  >> cares, this table probably could be converted to use IP-relative
  >> addresses, in which case this constraint could be dropped.

  Keith> In that case __ex_table should be moved to the same place as
  Keith> got, sdata, sbss.  As it stands, the gprel data is split with
  Keith> all the read only data plus init code between them.  ld does
  Keith> not detect errors for gprel in ex_table because __ex_table is
  Keith> not marked as short.

No, the gp-relative values in the exception table are 32-bits wide;
there is no 22-bit limitation there.

	--david

