From: "sudhnesh adapawar" <sudhnesh@gmail.com>
Date: Thu, 16 Nov 2006 07:19:24 +0000
Subject: How does the ski simulator resolves the dependency on shared libraries?
Message-Id: <9b33a9230611152307x6580a290n652ee50d9a5bda0c@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernelnewbies@nl.linux.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hey all,
          How does the ski simulator resolves the dependency on shared
libraries?
              For e.g: I tried 'ls' command on xski but i failed to run it :
[root@basemant /]# xski ls vmlinux simscsi=/var/ski-disks/sd
ls - No such file or directory
ls - No such file or directory
xski: Could not open ls for reading
[root@basemant /]# which ls
alias ls='ls --color=tty'
       /bin/ls
[root@basemant /]# xski /bin/ls vmlinux simscsi=/var/ski-disks/sd
/bin/ls - wrong architecture (3)
xski: Could not open /bin/ls for reading
[root@basemant /]#

Please kindly reply !

- Sudhnesh
