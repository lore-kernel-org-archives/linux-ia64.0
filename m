From: Matt_Domsch@Dell.com
Date: Fri, 27 Jul 2001 14:58:40 +0000
Subject: [Linux-ia64] efibootmgr 0.3.3-test3
Message-Id: <marc-linux-ia64-105590693005945@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've put a new efibootmgr 0.3.3-test3 up on http://domsch.com/linux/ia64.
This has the following updates:
* added -t flag for testing writing a variable out.  Writes it to a file,
does little else.  Somewhat helpful if you like emacs hexl-mode or similar.
* extra arguments passed to efibootmgr are now appended to the device path
as arguments to the boot loader.
* added -u flag to specify that those extra arguments should be appended in
UCS-2 format, not ASCII (default).
* -v should now display the extra arguments passed.  Unicode will have lots
of '.'s, as those are ASCII nulls.
* added test for getuid()=0 per suggestion.

My ia64 boxes are all down being upgraded to production-level hardware, so
testing has been minimal at best.  As always, I appreciate feedback (and
Andreas' patches!).

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!

