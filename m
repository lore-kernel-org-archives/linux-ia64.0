From: Mike Smith <msmith@freebsd.org>
Date: Tue, 24 Oct 2000 01:21:42 +0000
Subject: Re: [Linux-ia64] Making a CD that is readable under efi
Message-Id: <marc-linux-ia64-105590678205612@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205609@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205609@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> You need to create an El Torito bootable CD.  An El Torito bootable CD contains
> a floppy image (boot.img typically) that EFI can read.
> 
> I've never created an El Torito bootable CD, so I can't give details on that.
> 
> http://www.cdpage.com/Compact_Disc_Variations/bootablecd.html

If EFI can *only* read the boot image off an El Torito CD, I'd have to 
put that in the "extremely lame" category.  However, I wouldn't be 
surprised if EFI at the moment doesn't support the iso9660 filesystem; I 
certainly don't see anything in the EFI sample implementation which looks 
like it would do the trick.

You might want to poke the Intel boys and tell them to go steal some more 
code from the FreeBSD loader; they've done a great job so far turning it 
into platform firmware. 8)

-- 
... every activity meets with opposition, everyone who acts has his
rivals and unfortunately opponents also.  But not because people want
to be opponents, rather because the tasks and relationships force
people to take different points of view.  [Dr. Fritz Todt]
           V I C T O R Y   N O T   V E N G E A N C E



