From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 24 Oct 2000 01:13:37 +0000
Subject: Re: [Linux-ia64] Making a CD that is readable under efi
Message-Id: <marc-linux-ia64-105590678205610@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205609@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205609@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You need to create an El Torito bootable CD.  An El Torito bootable CD contains
a floppy image (boot.img typically) that EFI can read.

I've never created an El Torito bootable CD, so I can't give details on that.

http://www.cdpage.com/Compact_Disc_Variations/bootablecd.html

Jim

