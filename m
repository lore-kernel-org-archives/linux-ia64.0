From: "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com>
Date: Fri, 07 Dec 2001 19:47:04 +0000
Subject: RE: [Linux-ia64] mprotect problem
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C17F57.F26DD0D0"
Message-Id: <marc-linux-ia64-105590698805648@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805634@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805634@msgid-missing>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C17F57.F26DD0D0
Content-Type: text/plain;
	charset="ISO-8859-1"

OK, here's a trace.  The program is multi-threaded, so I used
strace -f.  Fortunately the problem happens almost right away.
At the very end, you can see the infinite loop starting.
One thing I noticed is that our printf's in the segv handler
are printing the fault
address as 20004000 while the mprotect is giving the address
as 6000000020004000.  This last address seems to be correct in 
relation to the original mprotect for the shared heap, which was

mprotect(0x6000000020000000, 268435456, PROT_NONE) = 0

Please let me know if this tells you anything interesting.

Jay

-----Original Message-----
From: David Mosberger [mailto:davidm@hpl.hp.com]
Sent: Friday, December 07, 2001 11:35 AM
To: Hoeflinger, Jay P
Cc: 'Boehm, Hans'; 'n0ano@indstorage.com'; 'linux-ia64@linuxia64.org'
Subject: RE: [Linux-ia64] mprotect problem


Jay,

If you don't have a minimal test program or can't share the source
code, it might be useful to collect a syscall trace.  That way, we
could see what addresses and sizes are involved in the mprotect()
call.  Something like:

	strace -o /tmp/out PROGNAME

should do (I'm assuming your program is not multithreaded; if it is,
you'd need to use the -f option and make sure you're running the
latest version of strace).

If the resulting output is very big, you won't be able to send it to
the mailing list.  You can either trim the output or just make sure
you mail it to me directly (davidm@hpl.hp.com).

Thanks,

	--david


------_=_NextPart_000_01C17F57.F26DD0D0
Content-Type: text/plain;
	name="strace-f.txt"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="strace-f.txt"

28563 execve("./stress.udp", ["stress.udp", "--", "-n2", "-N1", =
"-hodie", "-hodie", "-p5001", "-i1"], [/* 49 vars */]) =3D 0
28563 uname({sys=3D"Linux", node=3D"odie", ...}) =3D 0
28563 brk(0)                            =3D 0x60000000016efd90
28563 mmap(NULL, 16384, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0x2000000000030000
28563 open("/etc/ld.so.preload", O_RDONLY) =3D -1 ENOENT (No such file =
or directory)
28563 open("/opt/intel/compiler60/ia32/lib/libpthread.so.0", O_RDONLY) =
=3D -1 ENOENT (No such file or directory)
28563 SYS_1210(0x80000fffffffa5d0, 0x80000fffffffa920, =
0x4000000000000ec8, 0x200000000000ecc0, 0xc000000000001125, =
0x80000fffffffa5c0, 0x80000fffffffa5d0, 0) =3D -1 ENOENT (No such file =
or directory)
28563 open("/opt/intel/compiler60/ia64/lib/libpthread.so.0", O_RDONLY) =
=3D -1 ENOENT (No such file or directory)
28563 SYS_1210(0x80000fffffffa5d0, 0x80000fffffffa920, =
0x4000000000000ec8, 0x200000000000ecc0, 0xc000000000001125, =
0x80000fffffffa5c0, 0x80000fffffffa5d0, 0) =3D 0
28563 open("/etc/ld.so.cache", O_RDONLY) =3D 3
28563 SYS_1212(0x3, 0x80000fffffffa920, 0x200000000003db30, =
0x200000000000f810, 0xc000000000000898, 0x80000fffffffa9a0, 0x169bb, =
0x1) =3D 0
28563 mmap(NULL, 83870, PROT_READ, MAP_PRIVATE, 3, 0) =3D =
0x2000000000040000
28563 close(3)                          =3D 0
28563 open("/lib/libpthread.so.0", O_RDONLY) =3D 3
28563 read(3, =
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0002\0\1\0\0\0\0z\0\0"..., 1024) =3D =
1024
28563 SYS_1212(0x3, 0x80000fffffffa920, 0x80000fffffffa920, =
0x4000000000000ec8, 0x200000000000ecc0, 0xc000000000001125, =
0x80000fffffffa5c0, 0x80000fffffffa5d0) =3D 0
28563 mmap(NULL, 223544, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) =3D =
0x2000000000058000
28563 mprotect(0x2000000000074000, 108856, PROT_NONE) =3D 0
28563 mmap(0x2000000000078000, 98304, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_FIXED, 3, 0x10000) =3D 0x2000000000078000
28563 close(3)                          =3D 0
28563 open("/opt/intel/compiler60/ia64/lib/libc.so.6.1", O_RDONLY) =3D =
-1 ENOENT (No such file or directory)
28563 open("/lib/libc.so.6.1", O_RDONLY) =3D 3
28563 read(3, =
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0002\0\1\0\0\0\220\210"..., 1024) =
=3D 1024
28563 SYS_1212(0x3, 0x80000fffffffa8f0, 0x80000fffffffa5b0, =
0x20000000000305b0, 0x200000000000ecc0, 0xc000000000001125, =
0x80000fffffffa590, 0x80000fffffffa5a0) =3D 0
28563 mmap(NULL, 2422816, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) =3D =
0x2000000000090000
28563 mprotect(0x20000000002c0000, 129056, PROT_NONE) =3D 0
28563 mmap(0x20000000002c0000, 114688, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_FIXED, 3, 0x220000) =3D 0x20000000002c0000
28563 mmap(0x20000000002dc000, 14368, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0x20000000002dc000
28563 close(3)                          =3D 0
28563 mmap(NULL, 16384, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0x2000000000034000
28563 munmap(0x2000000000040000, 83870) =3D 0
28563 getpid()                          =3D 28563
28563 rt_sigaction(SIGRT0, {0x2000000000035230, [], 0}, NULL, 8) =3D 0
28563 rt_sigaction(SIGRT1, {0x2000000000035248, [], 0}, NULL, 8) =3D 0
28563 rt_sigaction(SIGRT2, {0x2000000000035260, [], 0}, NULL, 8) =3D 0
28563 rt_sigprocmask(SIG_BLOCK, [RT0], NULL, 8) =3D 0
28563 _sysctl(0x80000fffffffb3c0)       =3D 0
28563 getpid()                          =3D 28563
28563 gettimeofday({1007753574, 244290}, NULL) =3D 0
28563 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D 3
28563 ioctl(3, SIOCGIFCONF, 0x80000fffffffa620) =3D 0
28563 close(3)                          =3D 0
28563 brk(0)                            =3D 0x60000000016efd90
28563 brk(0x60000000016efdf0)           =3D 0x60000000016efdf0
28563 brk(0x60000000016f0000)           =3D 0x60000000016f0000
28563 brk(0x60000000016f4000)           =3D 0x60000000016f4000
28563 gettimeofday({1007753574, 245618}, NULL) =3D 0
28563 getpid()                          =3D 28563
28563 open("/etc/resolv.conf", O_RDONLY) =3D 3
28563 SYS_1212(0x3, 0x80000fffffff7ec0, 0, 0x1f7, 0x80000fffffffa5b0, =
0x20000000000305b0, 0x200000000000ecc0, 0xc000000000001125) =3D 0
28563 mmap(NULL, 65536, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0x2000000000040000
28563 read(3, "nameserver 172.31.250.101\nnamese"..., 16384) =3D 52
28563 read(3, "", 16384)                =3D 0
28563 close(3)                          =3D 0
28563 munmap(0x2000000000040000, 65536) =3D 0
28563 uname({sys=3D"Linux", node=3D"odie", ...}) =3D 0
28563 socket(PF_UNIX, SOCK_STREAM, 0)   =3D 3
28563 connect(3, {sin_family=3DAF_UNIX, path=3D"                        =
                                                               =
/var/run/.nscd_socket"}, 110) =3D -1 ENOENT (No such file or directory)
28563 close(3)                          =3D 0
28563 open("/etc/nsswitch.conf", O_RDONLY) =3D 3
28563 SYS_1212(0x3, 0x80000fffffffa0e0, 0x60000000016f0200, =
0x60000000016f01f8, 0x200000000017b830, 0xc000000000000205, =
0x60000000016f0260, 0x2000000000040000) =3D 0
28563 mmap(NULL, 65536, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0x2000000000040000
28563 read(3, "#\n# /etc/nsswitch.conf\n#\n# An ex"..., 16384) =3D 1782
28563 read(3, "", 16384)                =3D 0
28563 close(3)                          =3D 0
28563 munmap(0x2000000000040000, 65536) =3D 0
28563 open("/opt/intel/compiler60/ia64/lib/libnss_files.so.2", =
O_RDONLY) =3D -1 ENOENT (No such file or directory)
28563 open("/etc/ld.so.cache", O_RDONLY) =3D 3
28563 SYS_1212(0x3, 0x80000ffffffee030, 0x200000000003db30, =
0x200000000000f810, 0xc000000000000898, 0x80000ffffffee0b0, 0x26abb, =
0x80000ffffffedce0) =3D 0
28563 mmap(NULL, 83870, PROT_READ, MAP_PRIVATE, 3, 0) =3D =
0x2000000000040000
28563 close(3)                          =3D 0
28563 open("/lib/libnss_files.so.2", O_RDONLY) =3D 3
28563 read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0002\0\1\0\0\0 =
<\0\0"..., 1024) =3D 1024
28563 SYS_1212(0x3, 0x80000ffffffee030, 0x80000ffffffedd08, =
0x80000ffffffeeb68, 0x200000000000ecc0, 0xc000000000001125, =
0x80000ffffffedcd0, 0x80000ffffffedce0) =3D 0
28563 mmap(NULL, 152288, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) =3D =
0x20000000002e0000
28563 mprotect(0x20000000002f8000, 53984, PROT_NONE) =3D 0
28563 mmap(0x2000000000300000, 32768, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_FIXED, 3, 0x10000) =3D 0x2000000000300000
28563 close(3)                          =3D 0
28563 munmap(0x2000000000040000, 83870) =3D 0
28563 open("/etc/host.conf", O_RDONLY)  =3D 3
28563 SYS_1212(0x3, 0x80000fffffffa010, 0x2000000000290520, =
0xc000000000000207, 0x80000ffffffee810, 0, 0x200000000003da40, =
0x200000000028e6b0) =3D 0
28563 mmap(NULL, 65536, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0x2000000000040000
28563 read(3, "order hosts,bind\n", 16384) =3D 17
28563 read(3, "", 16384)                =3D 0
28563 close(3)                          =3D 0
28563 munmap(0x2000000000040000, 65536) =3D 0
28563 open("/etc/hosts", O_RDONLY)      =3D 3
28563 fcntl(3, F_GETFD)                 =3D 0
28563 fcntl(3, F_SETFD, FD_CLOEXEC)     =3D 0
28563 SYS_1212(0x3, 0x80000fffffff9e20, 0x80000ffffffee028, =
0x20000000003052e0, 0x80000ffffffedf08, 0x252e0, 0x80000ffffffee290, =
0x80000ffffffedee0) =3D 0
28563 mmap(NULL, 65536, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0x2000000000040000
28563 read(3, "################################"..., 16384) =3D 14421
28563 close(3)                          =3D 0
28563 munmap(0x2000000000040000, 65536) =3D 0
28563 write(2, "Tmk_startup: SWAPDIR=3D(null), put"..., 58) =3D 58
28563 getpid()                          =3D 28563
28563 open("/tmp/Tmk_swap.28563", O_RDWR|O_CREAT|O_TRUNC, 0600) =3D 3
28563 unlink("/tmp/Tmk_swap.28563")     =3D 0
28563 lseek(3, 268435455, SEEK_END)     =3D 268435455
28563 write(3, "\0", 1)                 =3D 1
28563 mmap(0x6000000020000000, 268435456, PROT_READ|PROT_WRITE, =
MAP_SHARED, 3, 0) =3D 0x6000000020000000
28563 mmap(0x6000000040000000, 268435456, PROT_READ|PROT_WRITE, =
MAP_SHARED, 3, 0) =3D 0x6000000040000000
28563 close(3)                          =3D 0
28563 mprotect(0x6000000020000000, 268435456, PROT_NONE) =3D 0
28563 mmap(NULL, 278528, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0x2000000000308000
28563 mmap(NULL, 1064960, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOU=
S, -1, 0) =3D 0x200000000034c000
28563 mmap(NULL, 1064960, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0x2000000000450000
28563 rt_sigaction(SIGSEGV, {0x20000000000352a8, [], SA_SIGINFO}, NULL, =
8) =3D 0
28563 rt_sigaction(SIGBUS, {0x20000000000352a8, [], SA_SIGINFO}, NULL, =
8) =3D 0
28563 brk(0x60000000016f8000)           =3D 0x60000000016f8000
28563 brk(0x60000000016fc000)           =3D 0x60000000016fc000
28563 brk(0x6000000001700000)           =3D 0x6000000001700000
28563 brk(0x6000000001704000)           =3D 0x6000000001704000
28563 brk(0x6000000001708000)           =3D 0x6000000001708000
28563 brk(0x600000000170c000)           =3D 0x600000000170c000
28563 brk(0x6000000001710000)           =3D 0x6000000001710000
28563 brk(0x6000000001714000)           =3D 0x6000000001714000
28563 brk(0x6000000001718000)           =3D 0x6000000001718000
28563 brk(0x600000000171c000)           =3D 0x600000000171c000
28563 brk(0x6000000001720000)           =3D 0x6000000001720000
28563 brk(0x6000000001724000)           =3D 0x6000000001724000
28563 brk(0x6000000001728000)           =3D 0x6000000001728000
28563 brk(0x600000000172c000)           =3D 0x600000000172c000
28563 brk(0x6000000001730000)           =3D 0x6000000001730000
28563 brk(0x6000000001734000)           =3D 0x6000000001734000
28563 rt_sigaction(SIGALRM, {0x20000000000352c0, [], 0}, NULL, 8) =3D 0
28563 rt_sigprocmask(SIG_BLOCK, [ALRM], NULL, 8) =3D 0
28563 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D 3
28563 getsockopt(3, SOL_SOCKET, SO_RCVBUF, [65535], [4]) =3D 0
28563 getsockopt(3, SOL_SOCKET, SO_SNDBUF, [65535], [4]) =3D 0
28563 bind(3, {sin_family=3DAF_INET, sin_port=3Dhtons(0), =
sin_addr=3Dinet_addr("0.0.0.0")}}, 16) =3D 0
28563 getsockname(3, {sin_family=3DAF_INET, sin_port=3Dhtons(32811), =
sin_addr=3Dinet_addr("0.0.0.0")}}, [16]) =3D 0
28563 getrlimit(RLIMIT_NOFILE, {rlim_cur=3D1024, rlim_max=3D1024}) =3D =
0
28563 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D 4
28563 getsockopt(4, SOL_SOCKET, SO_RCVBUF, [65535], [4]) =3D 0
28563 getsockopt(4, SOL_SOCKET, SO_SNDBUF, [65535], [4]) =3D 0
28563 bind(4, {sin_family=3DAF_INET, sin_port=3Dhtons(5001), =
sin_addr=3Dinet_addr("0.0.0.0")}}, 16) =3D 0
28563 recvmsg(4, {msg_name(16)=3D{sin_family=3DAF_INET, =
sin_port=3Dhtons(32810), sin_addr=3Dinet_addr("192.168.83.151")}}, =
msg_iov(2)=3D[{" \0\0\0\0\4\0\0", 8}, {")\200\0\0", 4}], =
msg_controllen=3D0, msg_flags=3D0}, 0) =3D 12
28563 connect(4, {sin_family=3DAF_INET, sin_port=3Dhtons(32810), =
sin_addr=3Dinet_addr("192.168.83.151")}}, 16) =3D 0
28563 send(4, " \0\0\0", 4, 0)          =3D 4
28563 close(4)                          =3D 0
28563 socket(PF_UNIX, SOCK_STREAM, 0)   =3D 4
28563 connect(4, {sin_family=3DAF_UNIX, path=3D"                        =
                                                               =
/var/run/.nscd_socket"}, 110) =3D -1 ENOENT (No such file or directory)
28563 close(4)                          =3D 0
28563 open("/etc/hosts", O_RDONLY)      =3D 4
28563 fcntl(4, F_GETFD)                 =3D 0
28563 fcntl(4, F_SETFD, FD_CLOEXEC)     =3D 0
28563 SYS_1212(0x4, 0x80000fffffffa0f0, 0x80000ffffffee0c8, 0x3, =
0x200000000002a700, 0x200000000003dbf8, 0x80000ffffffee030, =
0x80000ffffffedfd0) =3D 0
28563 mmap(NULL, 65536, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0x2000000000040000
28563 read(4, "################################"..., 16384) =3D 14421
28563 close(4)                          =3D 0
28563 munmap(0x2000000000040000, 65536) =3D 0
28563 socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D 4
28563 getsockopt(4, SOL_SOCKET, SO_RCVBUF, [65535], [4]) =3D 0
28563 getsockopt(4, SOL_SOCKET, SO_SNDBUF, [65535], [4]) =3D 0
28563 bind(4, {sin_family=3DAF_INET, sin_port=3Dhtons(0), =
sin_addr=3Dinet_addr("0.0.0.0")}}, 16) =3D 0
28563 connect(4, {sin_family=3DAF_INET, sin_port=3Dhtons(32809), =
sin_addr=3Dinet_addr("192.168.83.151")}}, 16) =3D 0
28563 sendmsg(4, {msg_name(0)=3DNULL, =
msg_iov(3)=3D[{"!\0\0\0\10\4\342\345", 8}, {"+\200\0\0", 4}, {"", 0}], =
msg_controllen=3D0, msg_flags=3D0}, 0) =3D 12
28563 setitimer(ITIMER_REAL, {it_interval=3D{1, 0}, it_value=3D{1, 0}}, =
NULL) =3D 0
28563 rt_sigprocmask(SIG_UNBLOCK, [ALRM], [ALRM RT0], 8) =3D 0
28563 recv(4, "!\0\0\0", 4, 0)          =3D 4
28563 rt_sigprocmask(SIG_SETMASK, [ALRM RT0], NULL, 8) =3D 0
28563 recvmsg(3, {msg_name(16)=3D{sin_family=3DAF_INET, =
sin_port=3Dhtons(32813), sin_addr=3Dinet_addr("192.168.83.151")}}, =
msg_iov(3)=3D[{"@\0\0\0\0\4\342\345", 8}, {")\200\0\0", 4}, {"", 0}], =
msg_controllen=3D0, msg_flags=3D0}, 0) =3D 12
28563 connect(3, {sin_family=3DAF_INET, sin_port=3Dhtons(32813), =
sin_addr=3Dinet_addr("192.168.83.151")}}, 16) =3D 0
28563 send(3, "@\0\0\0", 4, 0)          =3D 4
28563 getrlimit(RLIMIT_STACK, {rlim_cur=3D60000*1024, =
rlim_max=3DRLIM_INFINITY}) =3D 0
28563 setrlimit(RLIMIT_STACK, {rlim_cur=3D1008*1024, =
rlim_max=3DRLIM_INFINITY}) =3D 0
28563 brk(0x6000000001740000)           =3D 0x6000000001740000
28563 pipe([653280, 536870912])         =3D 5
28563 SYS_1213(0x2000000000035140, 0x6000000001733320, 0x7fe0, 0xf00, =
0x5, 0x2000000000035140, 0x5, 0xf00) =3D 28566
28563 write(6, =
"\310`n\1\0\0\0`\5\0\0\0\0\0\0\0\0\0\0\0\0\0\200\210\7\0"..., 168) =3D =
168
28563 rt_sigprocmask(SIG_SETMASK, NULL, [ALRM RT0], 8) =3D 0
28563 write(6, "\0\220\10\0\0\0\0 =
\0\0\0\0\0\0\0\0\300\245\377\377\377"..., 168) =3D 168
28563 rt_sigprocmask(SIG_SETMASK, NULL, [ALRM RT0], 8) =3D 0
28563 rt_sigsuspend([ALRM] <unfinished ...>
28563 --- SIGRT0 (Real-time signal 0) ---
28563 <... rt_sigsuspend resumed> )     =3D -1 EINTR (Interrupted =
system call)
28563 rt_sigreturn()                    =3D ? (mask now [HUP QUIT USR1 =
USR2 PIPE TERM TTOU XCPU XFSZ PROF RT2 RT4 RT5 RT7 RT14 RT18 RT22 RT23 =
RT24 RT25 RT27 RT30 RT31])
28563 SYS_1212(0x1, 0x80000fffffffb030, 0x20000000002e6fb0, =
0xc000000000000a98, 0x6000000001733320, 0x60000000016efe00, 0x3df, 0xa) =
=3D 0
28563 mmap(NULL, 65536, PROT_READ|PROT_WRITE, =
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D 0x2000000000040000
28563 ioctl(1, TCGETS, {B38400 opost isig icanon -echo ...}) =3D 0
28563 write(1, "Phase 0: distribute\n", 20) =3D 20
28563 write(1, "Phase 1: Locks and barriers\n", 28) =3D 28
28563 sendmsg(4, {msg_name(0)=3DNULL, =
msg_iov(5)=3D[{"A\0\0\0\10\0\0\0", 8}, =
{"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 64}, =
{"\0\0\0\0\0\0\0\0", 8}, {NULL, 0}, {"\0\0", 2}], msg_controllen=3D0, =
msg_flags=3D0}, 0) =3D 82
28563 setitimer(ITIMER_REAL, {it_interval=3D{1, 0}, it_value=3D{1, 0}}, =
NULL) =3D 0
28563 rt_sigprocmask(SIG_UNBLOCK, [ALRM], [ALRM RT0], 8) =3D 0
28563 recvmsg(4, {msg_name(0)=3DNULL, msg_iov(3)=3D[{"A\0\0\0\0\0\0\0", =
8}, {NULL, 0}, =
{"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 32768}], =
msg_controllen=3D0, msg_flags=3D0}, 0) =3D 10
28563 rt_sigprocmask(SIG_SETMASK, [ALRM RT0], NULL, 8) =3D 0
28563 getpid()                          =3D 28563
28563 write(1, "Trying to acquire a lock:0\n", 27) =3D 27
28563 sendmsg(4, {msg_name(0)=3DNULL, =
msg_iov(3)=3D[{"a\0\0\0\10\16\0\0", 8}, =
{"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 64}, =
{"\0\0", 2}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 74
28563 setitimer(ITIMER_REAL, {it_interval=3D{1, 0}, it_value=3D{1, 0}}, =
NULL) =3D 0
28563 rt_sigprocmask(SIG_UNBLOCK, [ALRM], [ALRM RT0], 8) =3D 0
28563 select(5, [4], NULL, NULL, NULL)  =3D 1 (in [4])
28563 recv(4, =
"a\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 32768, 0) =
=3D 136
28563 rt_sigprocmask(SIG_SETMASK, [ALRM RT0], NULL, 8) =3D 0
28563 write(1, "Accessing widgets index:0\n", 26) =3D 26
28563 write(1, "Address:20004000\n", 17) =3D 17
28563 --- SIGSEGV (Segmentation fault) ---
28563 write(1, "segv handler\n", 13)    =3D 13
28563 write(1, "Virt addr:20004000 1hello1\n", 27) =3D 27
28563 write(1, "addr:20004000\n", 14)   =3D 14
28563 write(1, "hello4\n", 7)           =3D 7
28563 send(4, "\201\0\0\0\10\20\1\0", 8, 0) =3D 8
28563 setitimer(ITIMER_REAL, {it_interval=3D{1, 0}, it_value=3D{1, 0}}, =
NULL) =3D 0
28563 rt_sigprocmask(SIG_UNBLOCK, [ALRM], [SEGV ALRM RT0], 8) =3D 0
28563 recvmsg(4, {msg_name(0)=3DNULL, msg_iov(2)=3D[{"\201\0\0\0", 4}, =
{"\0\0\0\0\0\0\360?\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 16384}], =
msg_controllen=3D0, msg_flags=3D0}, 0) =3D 16388
28563 rt_sigprocmask(SIG_SETMASK, [SEGV ALRM RT0], NULL, 8) =3D 0
28563 write(1, "hello7\n", 7)           =3D 7
28563 write(1, "hello6\n", 7)           =3D 7
28563 write(1, "hello8\n", 7)           =3D 7
28563 write(1, "hello10\n", 8)          =3D 8
28563 write(1, "hello13\n", 8)          =3D 8
28563 write(1, "hello12\n", 8)          =3D 8
28563 write(1, "hello11\n", 8)          =3D 8
28563 mprotect(0x6000000020004000, 16384, PROT_READ) =3D 0
28563 gettimeofday({1007753574, 334744}, NULL) =3D 0
28563 rt_sigprocmask(SIG_BLOCK, NULL, [SEGV ALRM RT0], 8) =3D 0
28563 rt_sigprocmask(SIG_UNBLOCK, [RT0], [SEGV ALRM RT0], 8) =3D 0
28563 gettimeofday({1007753574, 336194}, NULL) =3D 0
28563 nanosleep({0, 8550000}, NULL)     =3D 0
28563 rt_sigprocmask(SIG_SETMASK, [SEGV ALRM RT0], NULL, 8) =3D 0
28563 write(1, "hello9\n", 7)           =3D 7
28563 write(1, "exiting segv handler\n", 21) =3D 21
28563 rt_sigreturn()                    =3D ? (mask now [ALRM RT0])
28563 --- SIGSEGV (Segmentation fault) ---
28563 write(1, "segv handler\n", 13)    =3D 13
28563 write(1, "Virt addr:20004000 1hello1\n", 27) =3D 27
28563 write(1, "addr:20004000\n", 14)   =3D 14
28563 write(1, "hello2\n", 7)           =3D 7
28563 write(1, "hello9\n", 7)           =3D 7
28563 write(1, "exiting segv handler\n", 21) =3D 21
28563 rt_sigreturn()                    =3D ? (mask now [ALRM RT0])
28563 --- SIGSEGV (Segmentation fault) ---

------_=_NextPart_000_01C17F57.F26DD0D0--

