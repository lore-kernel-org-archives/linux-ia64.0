From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 15 Mar 2002 23:01:42 +0000
Subject: [Linux-ia64] qla1280.c v3.23.13
Message-Id: <marc-linux-ia64-105590701905300@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi

I have made some more changes to the qla1280 driver. A lot of it is
still cosmetic in order to bring the driver into a state where the code
will actually be maintainable. There is still quite a lot of work to do,
but it's certainly getting better.

http://www.wildopensource.com/~jes/linux/qla-3.23.13.diff.gz

The patch is relative to David's 2.4.7pre1 release, if there's a wish
for a tarball (say someone wanting to test it in a non ia64 kernel) let
me know and I shall be happy to generate that as well.

Jes

Just one minor example (and yes the smaller file is the updated version):

jes@itanic:~/kernel/linux-2.5.7-pre1>ls -l ../tmp/linux-2.5.7-pre1/drivers/scsi/qla1280.c drivers/scsi/qla1280.c
-r--r--r--    1 jes      jes        213984 Mar 15 18:32 ../tmp/linux-2.5.7-pre1/drivers/scsi/qla1280.c
-rw-r--r--    1 jes      jes        197604 Mar 15 18:27 drivers/scsi/qla1280.c

