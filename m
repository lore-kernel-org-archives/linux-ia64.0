From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 01 Mar 2006 18:59:20 +0000
Subject: gas is overly conservative with itc instruction
Message-Id: <B05667366EE6204181EABE9C1B1C0EB506C07A07@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It looks like gcc assembler is overly conservative in ensuring itc
is the last instruction in an instruction group.

The stop after first mmi bundle is unnecessary.  HJ, is it possible
to get that relaxed a bit?


a000000100000120:       4b 01 48 00 2f 04       [MMI] (p10) itc.i r18;;
a000000100000126:       00 00 00 02 00 00                   nop.m 0x0
a00000010000012c:       00 00 04 00                         nop.i 0x0;;
a000000100000130:       6a 01 48 00 2e 04       [MMI] (p11) itc.d r18;;
a000000100000136:       00 00 00 02 00 00                   nop.m 0x0
a00000010000013c:       00 00 04 00                         nop.i 0x0


- Ken
