From: Ken Burrell <ken.burrell@mscsoftware.com>
Date: Fri, 04 Apr 2003 07:08:52 +0000
Subject: Re: [Linux-ia64] IA64 Distributions
Message-Id: <marc-linux-ia64-105590723705416@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705322@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705322@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Brent Clements (bclem@rice.edu) said:

> 
> Does anyone know of a list of Freely available ia64 based distributions
> besides debian?


Yes, MSC.Software provides a free linux for ia64:

ftp://ftp.msclinux.com/mscbeta/ia64/March2003/install_dig.iso

Some of the features are:

kernel 2.4.19
glibc 2.2.5
gcc 3.2
KDE 3.1
XFree86 4.2.1
LSB compliance (certifcation in process of completion at this time)
Webmin system administration
NVidia cards supported with OpenGL and accelerated kernel driver
FireGL4 cards supported in graphical mode with non-accelerated X windows
devfs or traditional devices
XFS, ext3 and ext2 supported (and reiserfs after installation)
LVM available at installation time
rpm based with full database information on all files *and* directories
a set of cgi tools for creating clusters

No graphics card is required as long as you have a serial console and
CD-ROM drive.  You can also perform a graphical installation on such a
machine if you have a DHCP server on your network and a machine running
X windows to recieve the exported display.  This graphical machine does
not have to be an Itanium, or even running Linux.

Once you have a working installation on one machine, you may install to
another machine, even if it does not have a CD-ROM drive by using the
Netboot facility of EFI, and the provided cluster tools.  

The ability to easily perform a network boot is a wonderful feature of
EFI and the elilo.efi utility provided by Stephane Eranian of HP.

Ken Burrell

