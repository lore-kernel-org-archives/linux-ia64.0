From: "Ross A. Towle" <rat@cchkms.engr.sgi.com>
Date: Mon, 02 Oct 2000 16:36:16 +0000
Subject: [Linux-ia64] workaround-1.1.efi causes processors to be "stuck"
Message-Id: <marc-linux-ia64-105590678205530@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On a 4P Lion box with A3 processors, I have applied workaround-1.1.efi
with an argument of 3.  You see 4 messages that it has been applied.
However, during the Linux boot there are messages that processors 1, 2,
and 3 are "stuck".  And I endup with only one processor.  If I reboot
and don't applied workaround-1.1.efi then I endup with 4 processors.
This is with kernel-2.4.0test8-45.

Any idea on how to get multiple processors AND the stability that
workaround-1.1 provides?

-Ross

