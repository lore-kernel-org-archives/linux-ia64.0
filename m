From: Khalid Aziz <khalid@lyra.fc.hp.com>
Date: Fri, 29 Sep 2000 20:29:10 +0000
Subject: [Linux-ia64] ANNOUNCE: prctl tool
Message-Id: <marc-linux-ia64-105590678205529@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I have written a tool called "prctl" that allows you to run a program
with a different handling of unaligned memory access than the default.
You can choose for the process to get a SIGBUS on an unaligned access or
unaligned access to be handled silently by the kernel. You can also use
it to start a shell with modified unaligned access handling. Further
details are in the man page at the end. One use for this tool could be
to find and fix all unaligned memory accesses in a program while running
the program under gdb which may improve the performance.

prctl makes use of the new options to prctl system call introduced in
2.4.0-test7 kernel, so it will not work on kernels older than
2.4.0-test7.

I have built binary RPM packages for IA-64 and IA-32, and a source RPM
package. These can be downloaded from the following URLs:

<ftp://ftp.hpl.hp.com/pub/linux-ia64/prctl-1.0-1.ia64.rpm>
<ftp://ftp.hpl.hp.com/pub/linux-ia32/prctl-1.0-1.i386.rpm>
<ftp://ftp.hpl.hp.com/pub/linux-ia64/prctl-1.0-1.src.rpm>

Please feel free to give any feedback on this tool.

---
Khalid

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
Khalid Aziz                        Unix System Enablement Laboratory
(970)898-9214                                        Hewlett-Packard
khalid@fc.hp.com                                    Fort Collins, CO
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D


PRCTL(1)                                                 PRCTL(1)

NAME
       prctl - Process operations

SYNOPSIS
       prctl         [-v]         [-h|--help]         [--version]
       <-q|--unaligned=3D[silent|signal|default]> [command]

DESCRIPTION
       prctl allows you  to  query  or  control  certain  process
       behavior.   At  present, the only supported option is han=AD
       dling of unaligned memory accesses by a process.   When  a
       process  performs  an  unaligned memory access, by default
       the kernel would emulate the  unaligned  access  correctly
       and  log the unaligned access in syslog. This behavior can
       be  changed  so  the  kernel  could  either  emulate   the
       unaligned  access  correctly  without  logging an error or
       send SIGBUS to the process.

       prctl can optionally be followed by a command. If  a  com=AD
       mand  is  specified,  prctl will exec the command with the
       processor behavior set to as specified by the options.  If
       a  command  is  not specified, prctl will fork a new shell
       unless the command only queried the current settings.  The
       shell  started by prctl will be as defined by the environ=AD
       ment variable SHELL. If environment variable SHELL is  not
       defined,  shell in the password entry for the user will be
       started. If a shell is not found in  the  password  entry,
       bash will be started.

   OPTIONS
       -v     Verbose mode. In verbose mode, any new settings are
              confirmed with a message on stdout.

       --help Print usage information and exit.

       --version
              Print software version and exit.

       -q     Query the current settings for the process  options
              controllable by prctl.

       --unaligned=3D[silent|signal|default]]
              Set unaligned memory access behavior to not log the
              access (silent), send SIGBUS to the  process  (sig=AD
              nal),  or  do  the default (default). If a value is
              not  specified  after  "=3D",  current   setting   is
              returned.

       If  an  option  is  specified  multiple times, the last
              one takes effect.

EXAMPLES
       prctl --unaligned=3Dsignal
              starts  up  a  shell (as defined by the environment
              variable SHELL) and sets  up  any  process  running
              under   this  shell  to  be  sent  SIGBUS  upon  an
              unaligned memory access.

       prctl --unaligned=3Dsignal gdb tst
              starts up a gdb session for the program "tst"  with
              the  process  set  to  receive SIGBUS upon unligned
              memory access.

       prctl --unaligned              displays the current setting for  una=
ligned  memory
              access handling.

       prctl --unaligned=3D gdb tst
              displays  the  current setting for unaligned memory
              access handling and starts up a gdb session for the
              program "tst".

SEE ALSO
       prctl(2)

AUTHOR
       Khalid Aziz <khalid_aziz@hp.com>

LICENSE
       This software is made available under the GNU General Pub=AD
       lic License (GPL) Version 2.  This software comes with  NO
       WARRANTY.


