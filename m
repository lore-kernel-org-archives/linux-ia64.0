From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 31 Jul 2001 20:25:34 +0000
Subject: [Linux-ia64] Re: ia32 compatibility problem
Message-Id: <marc-linux-ia64-105590693005974@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005973@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005973@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 31 Jul 2001 15:41:22 -0400, Bill Nottingham <notting@redhat.com> said:

  Bill> Did abiword at least work with the warning?

No, it dies with a segfault.  The backtrace is attached below.  Note:
the symbol info is not complete, so some of the function names are
wrong.  For example, I don't think the function that crashes is
iconv_close().

	--david

(gdb) c
Continuing.

Program received signal SIGSEGV, Segmentation fault.
0x403b0b43 in iconv_close () from /usr/i386-glibc22-linux/lib/libc.so.6
1: x/i $eip  0x403b0b43 <iconv_close+1935>:	mov    (%esi),%eax
(gdb) bt
#0  0x403b0b43 in iconv_close () from /usr/i386-glibc22-linux/lib/libc.so.6
#1  0x403b02b7 in iconv () from /usr/i386-glibc22-linux/lib/libc.so.6
#2  0x080fc028 in UT_Mbtowc::mbtowc ()
#3  0x080f8b0f in UT_UCS_strcpy_char ()
#4  0x080e4199 in ap_sb_Field_PageInfo::getDesiredWidth ()
#5  0x080e3e5c in AP_StatusBar::setView ()
#6  0x080d04e3 in AP_UnixFrame::_showDocument ()
#7  0x080d0dd7 in AP_UnixFrame::loadDocument ()
#8  0x080d1b7c in AP_UnixFrame::loadDocument ()
#9  0x080cf859 in AP_UnixApp::parseCommandLine ()
#10 0x080cf2d4 in AP_UnixApp::main ()
#11 0x080ce01c in main ()
#12 0x403afd4c in __libc_start_main ()
   from /usr/i386-glibc22-linux/lib/libc.so.6

