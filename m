From: Matt_Domsch@Dell.com
Date: Tue, 03 Feb 2004 19:36:41 +0000
Subject: removing efibootmgr -t --test option
Message-Id: <1075837008.12773.6.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I received a request a few weeks ago to implement the EFI Boot Manager
Timeout value in efibootmgr.  This value controls the duration between
when the EFI Boot Manager displays the boot menu, and when it
automatically chooses the BootNext option.  I simply hadn't seen Timeout
in the spec, though it's been there since v0.99 at least.

The most logical efibootmgr option to use would be -t val  to specify a
timeout of val seconds, and -T  to delete it, following the other uses
of short-form options.  However, -t is currently short for --test, which
writes values to a file instead of NVRAM.

I expect I'm the only person who's ever used the -t option, it's really
for debugging purposes.  But, if it's regularly used elsewhere, such
that changing the meaning of -t would adversely impact someone, I won't
do it.  I'm looking for feedback.  If you use -t to mean --test, and it
would adversely affect you to use --test instead of -t, let me know
soon.

Thanks,
Matt


-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

