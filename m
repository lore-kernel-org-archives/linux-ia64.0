From: "MAGENHEIMER,DAN (HP-FtCollins,ex1)" <dan.magenheimer@hp.com>
Date: Fri, 31 Oct 2003 21:32:50 +0000
Subject: Booting diskless with 2.6.0-ia64?
Message-Id: <marc-linux-ia64-106763610225229@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone tried and successfully booted ia64 diskless
(e.g. CONFIG_ROOT_NFS) with 2.6.0 bits?  I've tried
on -test8 and haven't gotten it to work.  Perhaps
there are now additional CONFIG vars that need to be
turned on (other than CONFIG_ROOT_NFS, CONFIG_IP_PNP,
and CONFIG_IP_PNP_DHCP)?

I did discover that CONFIG_NFS_FS and the relevant
NICs all default to modules (which I would assume
wouldn't work when booting diskless :-) but changing
these to "y" didn't seem to fix it either.

Thanks,
Dan Magenheimer
HP Labs Fort Collins
