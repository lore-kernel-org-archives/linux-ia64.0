From: Matt_Domsch@Dell.com
Date: Fri, 10 Aug 2001 18:47:27 +0000
Subject: [Linux-ia64] efibootmgr-0.3.4 release
Message-Id: <marc-linux-ia64-105590698805059@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

New release efibootmgr 0.3.4 is now available at 
http://domsch.com/linux/ia64/efibootmgr-0.3.4.tar.gz.

Changes since 0.3.3:
- Applied patch from Richard Hirst to correct my bad maths.  Good catch
Richard!
- Added more uniqueness to the MBR signature if -w flag is used.  Now, the
field consists of:
    mbr->UniqueMBRSignature =  tv.tv_usec << 16;
    mbr->UniqueMBRSignature |= stat.st_rdev & 0xFFFF;
using fstat() and gettimeofday() to provide a fixed component and a
highly-likely-to-be-unique component.  This avoids the problem of moving a
disk from sda to sdb and installing on a new disk sda which would again
yield identical signatures.

As always, I really appreciate feedback (and patches!) from people.

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!

