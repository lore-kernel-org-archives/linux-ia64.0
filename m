From: "H. J. Lu" <hjl@lucon.org>
Date: Tue, 22 Jun 2004 22:43:02 +0000
Subject: Is vfat fs case sensitive in 2.6.7?
Message-Id: <20040622224302.GA953@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Under 2.4, I got

[root@gnu-4 efi]# cd /boot/efi/
[root@gnu-4 efi]# touch foo
[root@gnu-4 efi]# ls -l FOO
-rwxr-xr-x    1 root     root            0 Jun 22 15:41 FOO
[root@gnu-4 efi]#

Under 2.6.7, I got

[root@gnu-2 efi]# cd /boot/efi/
[root@gnu-2 efi]# touch foo
[root@gnu-2 efi]# ls -l FOO
ls: FOO: No such file or directory
[root@gnu-2 efi]#

Any ideas?


H.J.
