From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Fri, 01 Jan 2021 18:16:40 +0000
Subject: Re: [PATCH] sh: add support for TIF_NOTIFY_SIGNAL
Message-Id: <b16ed393-e2bf-deca-d0d9-614d24ee6406@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <5fcc82b4-89ae-3bca-10ab-6ad933565cee@kernel.dk>
 <ae29ab73-ee7a-2bb7-3fd8-3037f40c1cbd@kernel.dk>
 <5611bde9-67e7-6ff6-defc-9b02ea830fac@physik.fu-berlin.de>
 <9ea14eb3-d698-5499-ba4c-c6a3c35cd8d4@kernel.dk>
 <47f79645-53b7-b11c-167a-f5721b53df02@physik.fu-berlin.de>
 <9d9acec6-1e8c-2d68-5dfa-d58c11cf5cc4@kernel.dk>
 <070780c4-445e-6373-c8f4-1c72d0f3b4e0@physik.fu-berlin.de>
 <1047f3e5-4599-c34f-3176-9f41d2e1246b@kernel.dk>
 <31b34cfc-8d6e-d3b4-e29f-1ec485f5b368@physik.fu-berlin.de>
 <23bf4423-0987-c445-d5cd-1922e1e40820@kernel.dk>
 <f95539e9-506b-c4d9-2861-f288e2d021df@physik.fu-berlin.de>
 <10752e73-ca2a-9ea7-4aa6-35e366e36fb0@kernel.dk>
In-Reply-To: <10752e73-ca2a-9ea7-4aa6-35e366e36fb0@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-sh@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On 1/1/21 4:35 PM, Jens Axboe wrote:> It's supposed to finish very quickly:
>=20
> axboe@p1 ~> time ./socket-rw                                             =
                0.000s
>=20
> ________________________________________________________
> Executed in    1.10 millis    fish           external=20
>    usr time  888.00 micros  278.00 micros  610.00 micros=20
>    sys time   35.00 micros   35.00 micros    0.00 micros=20
>=20
> If it doesn't, can you try:
>=20
> # echo 1 > /sys/kernel/debug/tracing/events/io_uring/enable
>=20
> Then run the socket-rw app, and then do:
>=20
> # cat /sys/kernel/debug/tracing/trace
>=20
> and send that output? Might also be useful to include the strace
> of the socket-rw just in case, so maybe run it ala
>=20
> strace -o foo ./socket-rw
>=20
> and include foo in the reply as well.

Odd, I just ran it through strace and it exited immediately:

root@tirpitz:~> strace ./socket-rw=20
execve("./socket-rw", ["./socket-rw"], 0x7bb26670 /* 25 vars */) =3D 0
brk(NULL)                               =3D 0x412000
uname({sysname=3D"Linux", nodename=3D"tirpitz", ...}) =3D 0
access("/etc/ld.so.preload", R_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_LARGEFILE|O_CLOEXEC) =3D 3
fstat64(3, {st_mode=3DS_IFREG|0644, st_sized232, ...}) =3D 0
mmap2(NULL, 64232, PROT_READ, MAP_PRIVATE, 3, 0) =3D 0x29584000
close(3)                                =3D 0
mmap2(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
=3D 0x29574000
openat(AT_FDCWD, "/usr/lib/sh4-linux-gnu/liburing.so.1", O_RDONLY|O_LARGEFI=
LE|O_CLOEXEC) =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0*\0\1\0\0\0\324\17\0\0004\0\0\0=
"..., 512) =3D 512
fstat64(3, {st_mode=3DS_IFREG|0644, st_size=9536, ...}) =3D 0
mmap2(NULL, 73852, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) =
=3D 0x29594000
mprotect(0x29596000, 61440, PROT_NONE)  =3D 0
mmap2(0x295a5000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DEN=
YWRITE, 3, 0x1000) =3D 0x295a5000
close(3)                                =3D 0
openat(AT_FDCWD, "/lib/sh4-linux-gnu/libc.so.6", O_RDONLY|O_LARGEFILE|O_CLO=
EXEC) =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0*\0\1\0\0\0\224\306\1\0004\0\0\=
0"..., 512) =3D 512
pread64(3, "\4\0\0\0\20\0\0\0\1\0\0\0GNU\0\0\0\0\0\3\0\0\0\2\0\0\0\0\0\0\0"=
, 32, 1290836) =3D 32
fstat64(3, {st_mode=3DS_IFREG|0755, st_size=1297036, ...}) =3D 0
mmap2(NULL, 1366256, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) =
=3D 0x295a8000
mprotect(0x296e1000, 61440, PROT_NONE)  =3D 0
mmap2(0x296f0000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DE=
NYWRITE, 3, 0x138000) =3D 0x296f0000
mmap2(0x296f4000, 6384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANO=
NYMOUS, -1, 0) =3D 0x296f4000
close(3)                                =3D 0
mprotect(0x296f0000, 8192, PROT_READ)   =3D 0
mprotect(0x295a5000, 4096, PROT_READ)   =3D 0
mprotect(0x410000, 4096, PROT_READ)     =3D 0
mprotect(0x29582000, 4096, PROT_READ)   =3D 0
munmap(0x29584000, 64232)               =3D 0
socket(AF_INET, SOCK_STREAM|SOCK_CLOEXEC, IPPROTO_TCP) =3D 3
setsockopt(3, SOL_SOCKET, SO_REUSEPORT, [1], 4) =3D 0
setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
bind(3, {sa_family=AF_INET, sin_port=3Dhtons(13586), sin_addr=3Dinet_addr("=
127.0.0.1")}, 16) =3D 0
listen(3, 128)                          =3D 0
socket(AF_INET, SOCK_STREAM|SOCK_CLOEXEC, IPPROTO_TCP) =3D 4
setsockopt(4, SOL_TCP, TCP_NODELAY, [1], 4) =3D 0
fcntl64(4, F_GETFL)                     =3D 0x2 (flags O_RDWR)
fcntl64(4, F_SETFL, O_RDWR|O_NONBLOCK)  =3D 0
connect(4, {sa_family=AF_INET, sin_port=3Dhtons(13586), sin_addr=3Dinet_add=
r("127.0.0.1")}, 16) =3D -1 EINPROGRESS (Operation now in progress)
fcntl64(4, F_GETFL)                     =3D 0x802 (flags O_RDWR|O_NONBLOCK)
fcntl64(4, F_SETFL, O_RDWR)             =3D 0
accept(3, NULL, NULL)                   =3D 5
getsockopt(4, SOL_SOCKET, SO_ERROR, [0], [4]) =3D 0
io_uring_setup(32, {flags=3D0, sq_thread_cpu=3D0, sq_thread_idle=3D0, sq_en=
tries2, cq_entriesd, features=3DIORING_FEAT_SINGLE_MMAP|IORING_FEAT_NODROP|=
IORING_FEAT_SUBMIT_STABLE|IORING_FEAT_RW_CUR_POS|IORING_FEAT_CUR_PERSONALIT=
Y|0x1e0, sq_off=3D{head=3D0, tail=3D4, ring_mask=16, ring_entries$, flags6,=
 dropped2, array=1072}, cq_off=3D{head=3D8, tail=12, ring_mask , ring_entri=
es(, overflowD, cqesH, resv=3D[0x28, 0]}}) =3D 6
mmap2(NULL, 1200, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_POPULATE, 6, 0) =3D =
0x29576000
mmap2(NULL, 2048, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_POPULATE, 6, 0x10000=
000) =3D 0x29578000
io_uring_enter(6, 2, 2, IORING_ENTER_GETEVENTS, NULL, 8) =3D 2
munmap(0x29578000, 2048)                =3D 0
munmap(0x29576000, 1200)                =3D 0
close(6)                                =3D 0
exit_group(0)                           =3D ?
+++ exited with 0 +++
root@tirpitz:~>

--=20
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
