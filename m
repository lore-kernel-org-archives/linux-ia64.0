From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 07 Mar 2001 18:06:35 +0000
Subject: Re: [Linux-ia64] Two questions
Message-Id: <marc-linux-ia64-105590693005259@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005254@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005254@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>1. Where can I get precise info about firmware revisions, etc etc? I only know
>about what a 'ver' displays at the EFI prompt and what the files in /proc
>display... As to noting the 30+ digit BIOS revision, I do it by hand for now...

Reboot.  When you get to the blue Itanium splash screen, choose setup instead
of boot.  Scroll right until you get to the BIOS tab, the first field will
give a long string that contains the BIOS version number in the middle.
Usually it is ".00XX." where XX is the BIOS version number, but there are a
few exceptions, e.g. there is a BIOS 89B which displays as ".089B.".

Jim

