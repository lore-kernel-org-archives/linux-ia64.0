From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 02 May 2000 20:48:30 +0000
Subject: Re: [Linux-ia64] new kernel diff (relative to v2.3.99-pre6)
Message-Id: <marc-linux-ia64-105590678205063@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205032@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205032@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Gee, my 2.3.99-pre6 tree sure doesn't look anything like Linus's tar
ball!  I must have missed a patch at one point or another.  I'm
working on updating the patch...

	--david

>>>>> On Tue, 2 May 2000 12:17:02 -0700, Kevin Buettner <kev@primenet.com> said:

  Kevin> On May 1, 11:59pm, David Mosberger wrote:

  >> The full diff is at ftp.kernel.org:/pub/linux/kernel/ports/ia64/
  >> in:
  >> 
  >> linux-2.3.99-pre6-ia64-000501.diff.bz2

  Kevin> I'm getting some rejects when I attempt to apply this patch
  Kevin> against linux-2.3.99-pre6.tar.bz2.  Specifically,

  Kevin> $ bzip2 -dc ../../linux-2.3.99-pre6-ia64-000501.diff.bz2 |
  Kevin> patch -p1 [...]  patching file `drivers/ide/ide-cd.c' Hunk #1
  Kevin> FAILED at 2075.  Hunk #2 FAILED at 2100.  2 out of 2 hunks
  Kevin> FAILED -- saving rejects to drivers/ide/ide-cd.c.rej patching
  Kevin> file `drivers/usb/devices.c' Hunk #1 succeeded at 53 with
  Kevin> fuzz 2.  patching file `drivers/usb/uhci.c' Hunk #3 succeeded
  Kevin> at 2340 (offset 108 lines).  patching file `init/main.c' Hunk
  Kevin> #1 succeeded at 109 (offset 4 lines).  Hunk #2 FAILED at 527.
  Kevin> 1 out of 2 hunks FAILED -- saving rejects to init/main.c.rej

  Kevin> (Most of the patch succeeded; I'm only showing the parts that
  Kevin> had problems.)

  Kevin> Kevin

  Kevin> -- Kevin Buettner kev@primenet.com, kevinb@redhat.com


