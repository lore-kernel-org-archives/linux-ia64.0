From: Jean-Philippe BATTU <jean-philippe.battu@bull.net>
Date: Thu, 03 Oct 2002 09:47:41 +0000
Subject: [Linux-ia64] Problem to write a tape ..
Message-Id: <marc-linux-ia64-105590701906083@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi

I am trying to do some backups on an old exabyte 8505XL
on my IA64 system running with redhat 7.2

My device is the only one device on the scsi chain. I have
a terminator on this chain.

I can write little files (tar cvf /dev/st0 /etc/passwd) but
when I write large files (dump 0f /dev/st0 /dev/sda3) I get an
error on the dump or tar command :

  DUMP: estimated 3323762 tape blocks.
  DUMP: Volume 1 started with block 1 at: Thu Oct  3 10:42:06 2002
  DUMP: dumping (Pass III) [directories]
  DUMP: dumping (Pass IV) [regular files]
  DUMP: write error 49000 blocks into volume 1: Input/output error

with on the log message files :
 kernel: st0: Error 27070000 (sugg. bt 0x20, driver bt 0x7, host bt 0x7)

I encountered this problem on redhat 7.1 but the problem seems
persisted in redhat 7.2

I looked for some informations about this error messages but all
the documents I found where about the termination string, and all
is ok

Could you help me ?
Any suggestions would be greatly appreciated

Thanks

--

---------------------------------------------------------------------
Jean-Philippe BATTU            Phone   : (33) 04 76 29 73 43
Localisation: B1/403              Fax     : (33) 04 76 29 75 18
Mail : jean-philippe.battu@bull.net

Bull, 01 Rue de Provence
B.P. 208
38432 Echirolles FRANCE
---------------------------------------------------------------------



