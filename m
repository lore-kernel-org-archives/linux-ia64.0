From: Ville Herva <vherva@niksula.hut.fi>
Date: Thu, 27 Dec 2001 09:45:01 +0000
Subject: [Linux-ia64] 2.4.16 + ia64-011128: Unable to execute a "rwx" program
Message-Id: <marc-linux-ia64-105590698805720@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

whale% pwd
/tmp
whale% df -hT .
Filesystem    Type    Size  Used Avail Use% Mounted on
/dev/sda1     ext3    3.4G  3.0G  248M  93% /
whale% ls -l ./prog
-rwxrwxr-x    1 vherva   vherva    4899088 Dec 27 10:56 ./prog
whale% stat ./prog
  File: "./prog"
  Size: 4899088         Blocks: 9600       IO Block: 16384  Regular File
Device: 801h/2049d      Inode: 309989      Links: 1    
Access: (0775/-rwxrwxr-x)  Uid: (  501/  vherva)   Gid: (  504/  vherva)
Access: Thu Dec 27 11:19:54 2001
Modify: Thu Dec 27 10:56:15 2001
Change: Thu Dec 27 11:21:25 2001

whale% file ./prog
./prog: ELF 64-bit LSB executable, IA-64 (Intel 64 bit architecture) version
1 (SYSV), dynamically linked (uses shared libs), stripped
whale% id
uidP1(vherva) gidP4(vherva) groupsP4(vherva)
whale% ./prog
zsh: no such file or directory: ./prog
whale% strace ./prog
execve("./prog", ["./prog"], [/* 14 vars */]) = 0
strace: exec: No such file or directory
whale% ldd ./prog
/usr/bin/ldd: ./prog: No such file or directory
whale% cat /proc/version  
Linux version 2.4.16 (root@whale) (gcc version 2.96 20000731
(Mandrake Linux 8.1 2.96-0.62mdk)) #1 SMP Thu Dec 6 14:18:27 EET 2001

This is a c++ program I compiled with the Intel compiler.

with 2.4.17rc2 + ia64-011214 an the symptoms are similar, but "strace ldd
./prog" crashes the machine (hard lockup, only alt-sysrq-b works.) With
2.4.16+011128 it doesn't crash, but gives

/usr/bin/ldd: ./prog: No such file or directory

Any ideas?

 
-- v --

v@iki.fi

