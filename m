From: Tomas Szepe <szepe@pinerecords.com>
Date: Sat, 20 Mar 2004 11:50:02 +0000
Subject: 2.4.25 + 040218.diff OOPS
Message-Id: <20040320115002.GF21377@louise.pinerecords.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="zYM0uCDKw75PZbzx"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I just got the following OOPS.  Running the dump through ksymoops doesn't
give me anything useful on account of these errors:

...
Warning (compare_maps): mismatch on symbol QUIRK_LIST, ksyms_base says e00000000480d6e0, System.map says e00000000461fe40.
Ignoring ksyms_base entry
Warning (compare_maps): mismatch on symbol SELECT_DRIVE, ksyms_base says e00000000480f070, System.map says e00000000461fbe0.
  Ignoring ksyms_base entry
...

The box is an HP integrity rx1600, bootup dmesg gzipped/attached.
The kernel (version $subj) has been compiled using gcc-3.3.3 and
binutils-2.14.90.0.8.  This is no particular distribution, I've
compiled the userland all by myself (there's no ia64 slackware).

Any help appreciated!

Mar 20 11:46:07 columbia kernel: bash[15068]: NaT consumption 2216203124768
Mar 20 11:46:07 columbia kernel: 
Mar 20 11:46:07 columbia kernel: Pid: 15068, CPU 0, comm:                 bash
Mar 20 11:46:07 columbia kernel: psr : 0000121008022038 ifs : 800000000000070f ip  : [<e000000004449e71>]    Not tainted
Mar 20 11:46:07 columbia kernel: ip is at (no symbol)
Mar 20 11:46:07 columbia kernel: unat: 0000000000000000 pfs : 0000000000000309 rsc : 0000000000000003
Mar 20 11:46:07 columbia kernel: rnat: 000000000000048c bsps: 0000000000000003 pr  : 0000000000056a59
Mar 20 11:46:07 columbia kernel: ldrs: 0000000000000000 ccv : 0000000000000121 fpsr: 0009804c0270033f
Mar 20 11:46:07 columbia kernel: csd : 0000000000000000 ssd : 0000000000000000
Mar 20 11:46:07 columbia kernel: b0  : e0000000045b88e0 b6  : e000000004402d60 b7  : e0000000045b0c80
Mar 20 11:46:07 columbia kernel: f6  : 0ffff8000000000000000 f7  : 000000000000000000000
Mar 20 11:46:07 columbia kernel: f8  : 000000000000000000000 f9  : 000000000000000000000
Mar 20 11:46:07 columbia kernel: f10 : 000000000000000000000 f11 : 000000000000000000000
Mar 20 11:46:07 columbia kernel: r1  : e000000004ad5d30 r2  : 0000000000000000 r3  : e0000000385b8000
Mar 20 11:46:07 columbia kernel: r8  : e0000000045b0c80 r9  : 0000000000000121 r10 : 0000000000000120
Mar 20 11:46:07 columbia kernel: r11 : 0000000000000121 r12 : e000000037257e00 r13 : e000000037250000
Mar 20 11:46:07 columbia kernel: r14 : e000000004818028 r15 : e0000000385b81b8 r16 : 0000000000000121
Mar 20 11:46:07 columbia kernel: r17 : 0000000000000001 r18 : fffffffffffffffe r19 : e0000000385b91e0
Mar 20 11:46:07 columbia kernel: r20 : 0000000000000000 r21 : e0000000385bb000 r22 : e0000000385b9b10
Mar 20 11:46:07 columbia kernel: r23 : 0000000000000020 r24 : 00000fffffffa420 r25 : 0000000000000000
Mar 20 11:46:07 columbia kernel: r26 : 0000000000000001 r27 : 0000000000000001 r28 : 60000fffffffa421
Mar 20 11:46:07 columbia kernel: r29 : 60000fffffffa420 r30 : 0000000000004000 r31 : 0000000000000001
Mar 20 11:46:07 columbia kernel: 
Mar 20 11:46:07 columbia kernel: Call Trace:
Mar 20 11:46:07 columbia kernel:  [<e00000000440f820>] (no symbol)
Mar 20 11:46:07 columbia kernel:                                 sp=e000000037257960 bsp=e0000000372510d0
Mar 20 11:46:07 columbia kernel:  [<e000000004429390>] (no symbol)
Mar 20 11:46:07 columbia kernel:                                 sp=e000000037257b30 bsp=e000000037251098
Mar 20 11:46:07 columbia kernel:  [<e00000000442a080>] (no symbol)
Mar 20 11:46:07 columbia kernel:                                 sp=e000000037257b30 bsp=e000000037251050
Mar 20 11:46:07 columbia kernel:  [<e00000000440a460>] (no symbol)
Mar 20 11:46:07 columbia kernel:                                 sp=e000000037257c30 bsp=e000000037251050
Mar 20 11:46:07 columbia kernel:  [<e000000004449e70>] (no symbol)
Mar 20 11:46:07 columbia kernel:                                 sp=e000000037257e00 bsp=e000000037250fd0
Mar 20 11:46:07 columbia kernel:  [<e0000000045b88e0>] (no symbol)
Mar 20 11:46:07 columbia kernel:                                 sp=e000000037257e00 bsp=e000000037250fa0
Mar 20 11:46:07 columbia kernel:  [<e0000000045af2a0>] (no symbol)
Mar 20 11:46:07 columbia kernel:                                 sp=e000000037257e00 bsp=e000000037250f80
Mar 20 11:46:07 columbia kernel:  [<e0000000045b29f0>] (no symbol)
Mar 20 11:46:07 columbia kernel:                                 sp=e000000037257e00 bsp=e000000037250ea0
Mar 20 11:46:07 columbia kernel:  [<e0000000045a95d0>] (no symbol)
Mar 20 11:46:07 columbia kernel:                                 sp=e000000037257e30 bsp=e000000037250e60
Mar 20 11:46:07 columbia kernel:  [<e0000000044a0140>] (no symbol)
Mar 20 11:46:07 columbia kernel:                                 sp=e000000037257e30 bsp=e000000037250dd8
Mar 20 11:46:07 columbia kernel:  [<e00000000440a260>] (no symbol)
Mar 20 11:46:07 columbia kernel:                                 sp=e000000037257e30 bsp=e000000037250dd8
Mar 20 11:47:51 columbia kernel:  <1>Unable to handle kernel NULL pointer dereferencemc[15066]: Oops 11012296146944
Mar 20 11:47:51 columbia kernel: 
Mar 20 11:47:51 columbia kernel: Pid: 15066, CPU 0, comm:                   mc
Mar 20 11:47:51 columbia kernel: psr : 0000121008026018 ifs : 800000000000038c ip  : [<e0000000045a7be1>]    Not tainted
Mar 20 11:47:51 columbia kernel: ip is at (no symbol)
Mar 20 11:47:51 columbia kernel: unat: 0000000000000000 pfs : 0000000000000894 rsc : 0000000000000003
Mar 20 11:47:51 columbia kernel: rnat: 0000000000000000 bsps: 0000000000000000 pr  : 000000000005a955
Mar 20 11:47:51 columbia kernel: ldrs: 0000000000000000 ccv : 0000000000000045 fpsr: 0009804c8a70433f
Mar 20 11:47:51 columbia kernel: csd : 0000000000000000 ssd : 0000000000000000
Mar 20 11:47:51 columbia kernel: b0  : e0000000045aa780 b6  : e000000004402d60 b7  : e0000000045abac0
Mar 20 11:47:51 columbia kernel: f6  : 1003e0000000000000000 f7  : 1003e0000000000000078
Mar 20 11:47:51 columbia kernel: f8  : 1003e000000000000dc61 f9  : 1003e000000000009782b
Mar 20 11:47:51 columbia kernel: f10 : 1003e0000000000000474 f11 : 1003e0000000000000000
Mar 20 11:47:51 columbia kernel: r1  : e000000004ad5d30 r2  : 0000000000000502 r3  : 0000000000000090
Mar 20 11:47:51 columbia kernel: r8  : e000000003ca0680 r9  : e000000006144588 r10 : e000000006144580
Mar 20 11:47:51 columbia kernel: r11 : e000000002ef5390 r12 : e00000003e0dfdf0 r13 : e00000003e0d8000
Mar 20 11:47:51 columbia kernel: r14 : e0000000048135a8 r15 : 0000000000000000 r16 : e0000000385b8ac8
Mar 20 11:47:51 columbia kernel: r17 : 0000000000005401 r18 : 0000000000005401 r19 : e0000000048bce44
Mar 20 11:47:51 columbia kernel: r20 : 0000000000000000 r21 : e000000003ca07b0 r22 : e0000000061479b0
Mar 20 11:47:51 columbia kernel: r23 : e0000000061479a8 r24 : e0000000048bce40 r25 : e0000000048d7b38
Mar 20 11:47:51 columbia kernel: r26 : e0000000048d6b48 r27 : e000000003c53288 r28 : e0000000048bc580
Mar 20 11:47:51 columbia kernel: r29 : e000000002ef5688 r30 : e000000002ef5680 r31 : e000000003c52088
Mar 20 11:47:51 columbia kernel: 
Mar 20 11:47:51 columbia kernel: Call Trace:
Mar 20 11:47:51 columbia kernel:  [<e00000000440f820>] (no symbol)
Mar 20 11:47:51 columbia kernel:                                 sp=e00000003e0df9c0 bsp=e00000003e0d9170
Mar 20 11:47:51 columbia kernel:  [<e000000004429390>] (no symbol)
Mar 20 11:47:51 columbia kernel:                                 sp=e00000003e0dfb90 bsp=e00000003e0d9138
Mar 20 11:47:51 columbia kernel:  [<e000000004444970>] (no symbol)
Mar 20 11:47:51 columbia kernel:                                 sp=e00000003e0dfb90 bsp=e00000003e0d90d8
Mar 20 11:47:51 columbia kernel:  [<e00000000440a460>] (no symbol)
Mar 20 11:47:51 columbia kernel:                                 sp=e00000003e0dfc20 bsp=e00000003e0d90d8
Mar 20 11:47:51 columbia kernel:  [<e0000000045a7be0>] (no symbol)
Mar 20 11:47:51 columbia kernel:                                 sp=e00000003e0dfdf0 bsp=e00000003e0d9078
Mar 20 11:47:51 columbia kernel:  [<e0000000045aa780>] (no symbol)
Mar 20 11:47:51 columbia kernel:                                 sp=e00000003e0dfdf0 bsp=e00000003e0d8fe8
Mar 20 11:47:51 columbia kernel:  [<e0000000045abae0>] (no symbol)
Mar 20 11:47:51 columbia kernel:                                 sp=e00000003e0dfe30 bsp=e00000003e0d8fc0
Mar 20 11:47:51 columbia kernel:  [<e0000000044a2440>] (no symbol)
Mar 20 11:47:51 columbia kernel:                                 sp=e00000003e0dfe30 bsp=e00000003e0d8f70
Mar 20 11:47:51 columbia kernel:  [<e00000000449ec40>] (no symbol)
Mar 20 11:47:51 columbia kernel:                                 sp=e00000003e0dfe30 bsp=e00000003e0d8f40
Mar 20 11:47:51 columbia kernel:  [<e0000000044575b0>] (no symbol)
Mar 20 11:47:51 columbia kernel:                                 sp=e00000003e0dfe30 bsp=e00000003e0d8ee0
Mar 20 11:47:51 columbia kernel:  [<e0000000044581d0>] (no symbol)
Mar 20 11:47:51 columbia kernel:                                 sp=e00000003e0dfe30 bsp=e00000003e0d8e50
Mar 20 11:47:51 columbia kernel:  [<e000000004458480>] (no symbol)
Mar 20 11:47:51 columbia kernel:                                 sp=e00000003e0dfe30 bsp=e00000003e0d8df0
Mar 20 11:47:51 columbia kernel:  [<e0000000045aa780>] (no symbol)
Mar 20 11:47:51 columbia kernel:                                 sp=e00000003e0dfe30 bsp=e00000003e0d8d98

-- 
Tomas Szepe <szepe@pinerecords.com>

--zYM0uCDKw75PZbzx
Content-Type: application/x-gunzip
Content-Disposition: attachment; filename="dmesg.gz"
Content-Transfer-Encoding: base64

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

--zYM0uCDKw75PZbzx--
