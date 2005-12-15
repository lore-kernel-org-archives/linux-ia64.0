From: Keith Owens <kaos@sgi.com>
Date: Thu, 15 Dec 2005 07:17:32 +0000
Subject: [ANNOUNCE] salinfo 1.0 is available
Message-Id: <13035.1134631052@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

There is a new and (so far) unofficial version of salinfo on
ftp://ftp.ocs.com.au, in /pub/salinfo-1.0.tar.bz2 and
salinfo-1.0-1.src.rpm.  I hope that they will move to the official HP
location soon.

The base functionality of salinfo has not changed, it still reads from
/proc/sal/{cmc,cpe,init,mca}/* and writes to /var/log/salinfo.  The
changes are above this layer and are aimed at making the salinfo code
more resilient, less of a potential denial of service and to make it
easier to post process the SAL records.

Note: you need this kernel patch to let salinfo_decode 1.0 see alarm
signals.  Without this patch it will still work, just not log the
dropped records correctly.

diff-tree 05f70395c642bed0300bc1955bfa8c0f93de2bc2 (from 885da19e8044051a92=
cfd70099398c373245c431)
Author: Keith Owens <kaos@sgi.com>
Date:   Fri Dec 2 13:40:15 2005 +1100

    [IA64] Allow salinfo_decode to detect signals on read
   =20
    Return -EINTR instead of -ERESTARTSYS when signals are delivered during
    a blocked read of /proc/sal/*/event.  This allows salinfo_decode to
    detect signals when it is blocked on a read of those files.
   =20
    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index ca68e6e..1461dc6 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -293,7 +293,7 @@ retry:
 		if (file->f_flags & O_NONBLOCK)
 			return -EAGAIN;
 		if (down_interruptible(&data->sem))
-			return -ERESTARTSYS;
+			return -EINTR;
 	}
=20
 	n =3D data->cpu_check;


Changelog extract for salinfo 1.0.

2005-12-14  Keith Owens  <kaos@sgi.com>

	* Released as 1.0.

	* salinfo_decode_all is now a C program instead of a shell script.  It
	  monitors the health of the salinfo_decode tasks.

	* Add salinfo_decode option -i pct, do not write records if the -D
	  filesystem inode percentage used is pct or greater.

	* Add salinfo_decode option -s pct, do not write records if the -D
	  filesystem space used percentage is pct or greater.

	* Add salinfo_decode option -l limit, limit the number of events per
	  minute.

	* Add salinfo_decode option -T filename, write a trigger record to
	  filename for each SAL record.

	* Site specific options can be set in /etc/sysconfig/salinfo_decode_all.

	* Count and log the number of dropped records.

	* Build allows separate source and object directories.

	* Fix use after free bug in read_salinfo_decode_oem().


Default /etc/sysconfig/salinfo_decode_all.

  # Define custom options in /etc/sysconfig/salinfo_decode_all
  #
  # All variables come in two forms, global (applies to all record types) a=
nd
  # per record (only applies to that record type).  The per record variables
  # have a prefix of 'CMC_', 'CPE_', 'INIT_' or 'MCA_', global settings hav=
e no
  # prefix.  The global value is used if there is no record specific variab=
le in
  # the environment.
  #
  # Required variables are :-
  #
  # DIRECTORY             The value passed as parameter -D to salinfo_decod=
e.
  #
  # RETRIES               How many times a version of salinfo_decode is res=
tarted
  #                       before we give up and log the failure.
  #
  # Optional variables are :-
  #
  # INODE_PCT             Passed as -i <value> to salinfo_decode.
  #
  # SPACE_PCT             Passed as -s <value> to salinfo_decode.
  #
  # RATE_LIMIT            Passed as -l <value> to salinfo_decode.
  #
  # TRIGGER               Passed as -T <value> to salinfo_decode.

  # Required variables
  export DIRECTORY=3D/var/log/salinfo
  export RETRIES=3D3

  # Optional variables, these are rule of thumb limits
  export INODE_PCT=90     # drop records if inodes used is >=3D 90%
  export SPACE_PCT=90     # drop records if space used is >=3D 90%
  export RATE_LIMIT=10    # drop records if more than 10/minute
  # TRIGGER=3D is not set, it only makes sense if you install a post proces=
sing program


Typical syslog entries from salinfo_decode_all when any of the
salinfo_decode children fail.

  Dec 15 06:27:50 salinfo_decode_all[2637]: Retry 1 for type INIT, previous=
 status was 15
  Dec 15 06:28:05 salinfo_decode_all[2637]: Type INIT died very quickly, no=
 respawn, last status was 15


Typical syslog entry when salinfo_decode drops records because of the
limits.  This one says that 6 records were dropped because the
filesystem was filling up and 5 records were dropped because they
exceeded the rate limit.

  Dec 13 16:31:56 salinfo_decode[21460]: 11 cpe records dropped since Tue D=
ec 13 16:31:39 2005, 6 -s pct, 5 -l limit


Typical syslog entry when salinfo_decode drops trigger records because
the post processing program is not working.  The actual cpe records
were still processed and saved, the only things lost in this case were
the post processing triggers.

  Dec 13 20:37:27 salinfo_decode[30292]: 4 cpe trigger records dropped sinc=
e Tue Dec 13 20:37:18 2005


We hope that we do not see this one :).  If all the children die and
they have reached their retry limit or they are dying too quickly, then
there is nothing that salinfo_decode_all can do.

  Dec 15 06:28:05 salinfo_decode_all[2637]: All children have died, giving =
up

