From: Keith Owens <kaos@sgi.com>
Date: Mon, 16 Dec 2002 09:00:23 +0000
Subject: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805569@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Another gas bug with ia64 unwind data in binutils-2.11.90.0.8-12.

arch/ia64/lib/memset.S generates unwind data of

<memset>: [0xe0020000005e07c0-0xe0020000005e0be0), info at +0x6aa5e8
  v1, flags=0x0 ( ), len=8 bytes
    R1:prologue(rlen=1)
    R3:body(rlen4)
        B3:epilogue(t=1,ecount890)

An epilogue count of 3890?  I think not.  But wait, it gets worse!  The
raw info data is

e0020000006aa5e8 01000000 00000100 0161c201 ea01b29e

0100      version 1
0000      no flags
01000000  ulen=1 (8 bytes), followed by 8 bytes 0161c201 ea01b29e

01        Prologue R1, rlen=1
61c201    Body R3, rlen4
ea        According to IA-64 Software Conventions and Runtime
          Architecture Guide August 2000 (24535802.pdf), Appendix B, ea
          is not a valid code, B3 records should be e0!  Why is gas
          generating ea?
01        t=1
b29e      uleb128 number with x80 set in both bytes!  We have reached
          the end of the data area (ulen=1) but uleb128 says there is
          more data to come.

Sorry for the surfeit of exclamation marks but the ia64 unwind code is
driving me up the wall.  I want kdb to backtrace correctly, all this
garbage data just gets in the way.


