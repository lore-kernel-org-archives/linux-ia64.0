From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jun 2004 05:03:27 +0000
Subject: top stack users
Message-Id: <200406100503.i5A53RHD026410@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thought I'd run "make checkstack" to see who the worst offenders are
in stack consumption (this is for 2.6.7-rc3):

0xa00000010002d986 pfm_overflow_handler:                2128
0xa00000010024c166 nfs_direct_write_seg:                1520
0xa000000100009f46 huft_build:                          1456
0xa00000010000dac6 huft_build:                          1456
0xa00000010024ba46 nfs_direct_read_seg:                 1440
0xa000000100193b26 elf_kcore_store_hdr:                 1376
0xa00000010000b9c6 inflate_dynamic:                     1296
0xa00000010000f686 inflate_dynamic:                     1296
0xa00000010000b686 inflate_fixed:                       1184
0xa00000010000f346 inflate_fixed:                       1184
0xa000000100413830 tg3_get_estats:                      1184
0xa0000001007ffba6 efi_uart_console_only:               1152

Stephane, I think pfm_overflow_handler() is a real problem and could
lead to stack-overflows.  The culprit appears to be the variable of
type "pfm_ovfl_arg_t".  It would be good if we could avoid such big
stack consumption.

efi_uart_console_only() also seems to be a bit on the high side, but
it's probably OK since it's used only once at boottime.

	--david
