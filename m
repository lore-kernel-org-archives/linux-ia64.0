From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Tue, 11 Feb 2003 13:27:15 +0000
Subject: [Linux-ia64] 2.5.59 & mmap_sem deadlock ?
Message-Id: <marc-linux-ia64-105590709805835@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

Running 2.5.59 ia64 kernel with CONFIG_NUMA set, it seems that the Xserver
sometimes deadlocks on the mmap_sem.
I am wondering if having a page fault in copy_page_range() is at the
origin of the problem or there is a recursion problem with the lock:

dup_mmap
	down_write(&oldmm->mmap_sem);
	copy_page_range
		ia64_do_page_fault
			down_read(&mm->mmap_sem);

traces --------------------------------------------------------------------=
--

[0]kdb> btp 1125=20
0xe0000001dc258000 00001125 00001115  0  003  stop  0xe0000001dc258600 X
0xe000000004468d90 schedule+0xa90
        args (0x9556958095595657, 0x4000, 0x0, 0xa0000000000127d8, 0xe00000=
0182344e90)
        kernel <NULL> 0x0 0xe000000004468300 0x0
0xe0000000046497a0 __down_read+0x1c0
        args (0xe0000001dc258000, 0x2, 0xe0000001dc25f9e8, 0xe0000000044499=
e0, 0x58f)
        kernel <NULL> 0x0 0xe0000000046495e0 0x0
0xe0000000044499e0 ia64_do_page_fault+0x220
        args (0xe0000001bc992a80, 0x80400000000, 0xe0000001dc25fa80, 0xe000=
0001ffff1e40, 0x20)
        kernel <NULL> 0x0 0xe0000000044497c0 0x0
0xe00000000440d6a0 ia64_leave_kernel
        args (0xe0000001bc992a80, 0x80400000000, 0xe0000001dc25fa80)
        kernel <NULL> 0x0 0xe00000000440d6a0 0x0
0xe0000000044ba070 copy_page_range+0x4d0
        args (0xe0000001fc74f680, 0xe0000001bc992a80, 0xe000001001f28428, 0=
x100ffffc0005b1, 0xe0000001c0500800)
        kernel <NULL> 0x0 0xe0000000044b9ba0 0x0
0xe000000004471830 dup_mmap+0x4d0
        args (0xe0000001fc74f680, 0xe0000001bc992ab8, 0xe000001001f28400, 0=
xe000003007832300, 0xe000001001f28450)
        kernel <NULL> 0x0 0xe000000004471360 0x0
0xe00000000446ef40 copy_mm+0x1c0
        args (0xe0000001fc74f680, 0xfffffffffffffff4, 0xe0000001bc992a80, 0=
xe0000001b1c980b0, 0xe0000001b1c980a8)
        kernel <NULL> 0x0 0xe00000000446ed80 0x0
[0]more>=20
0xe0000000044700c0 copy_process+0x800
        args (0x11, 0x0, 0xe0000001dc25fe70, 0x10, 0xe0000001b1c98118)
        kernel <NULL> 0x0 0xe00000000446f8c0 0x0
0xe000000004470f10 do_fork+0x70
        args (0x11, 0x0, 0xe0000001dc25fe70, 0x10, 0x4000000000153830)
        kernel <NULL> 0x0 0xe000000004470ea0 0x0
0xe00000000440d020 sys_clone+0x60
        args (0x11, 0x0, 0x4000000000153830, 0xc00000000000040d, 0xe0000000=
0440d680)
        kernel <NULL> 0x0 0xe00000000440cfc0 0x0
0xe00000000440d680 ia64_ret_from_syscall
        args (0x11, 0x0)
        kernel <NULL> 0x0 0xe00000000440d680 0x0

(gdb) print *(struct task_struct *)0xe0000001dc258000
$1 =3D {state =3D 2, thread_info =3D 0xe0000001dc258fd0, usage =3D {counter=
 =3D 7},=20
  flags =3D 256, ptrace =3D 0, lock_depth =3D -1, prio =3D 116, static_prio=
 =3D 120,=20
  run_list =3D {next =3D 0xe000000004b08f08, prev =3D 0xe000000004b08f08}, =

  array =3D 0x0, sleep_avg =3D 1953, sleep_timestamp =3D 604406, policy =3D=
 0,=20
  cpus_allowed =3D 18446744073709551615, time_slice =3D 111, first_time_sli=
ce =3D 0,=20
  tasks =3D {next =3D 0xe000002001740078, prev =3D 0xe0000001cb2d0078},=20
  ptrace_children =3D {next =3D 0xe0000001dc258088, prev =3D 0xe0000001dc25=
8088},=20
  ptrace_list =3D {next =3D 0xe0000001dc258098, prev =3D 0xe0000001dc258098=
},=20
  mm =3D 0xe0000001bc992a80, active_mm =3D 0xe0000001bc992a80,=20
...
(gdb) print *(struct mm_struct *)0xe0000001bc992a80
$2 =3D {mmap =3D 0xe0000001c0537e00, mm_rb =3D {rb_node =3D 0xe0000001c0537=
d30},=20
  mmap_cache =3D 0x0, free_area_cache =3D 2305843009213693952,=20
  pgd =3D 0xe0000001c2764000, mm_users =3D {counter =3D 4}, mm_count =3D {
    counter =3D 1}, map_count =3D 57, mmap_sem =3D {activity =3D -1, wait_l=
ock =3D {
						XXXXXXXXXXX
      lock =3D 0}, wait_list =3D {next =3D 0xe0000001dc25f9d0,=20
      prev =3D 0xe0000001c374fd10}}, page_table_lock =3D {lock =3D 1}, mmli=
st =3D {
							XXXX

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________

