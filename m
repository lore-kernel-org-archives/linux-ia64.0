From: chas williams <chas@cmf.nrl.navy.mil>
Date: Tue, 31 Jul 2001 10:57:15 +0000
Subject: [Linux-ia64] still patching syscall into module
Message-Id: <marc-linux-ia64-105590693005967@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

i solved my problem for the time being by linking directly with the
kernel.  i am again looking at trying to make patch the syscall
table to call a module.

the following does what i want:

GLOBAL_ENTRY(afs_syscall)
        movl r15=3D0xa0000000001749e0;;
        ld8 r16=3D[r15],8
        mov r14=3Dgp;;
        ld8 gp=3D[r15]
        mov b6=3Dr16;;
        br.few b6
END(afs_syscall)

however, its rather inconvenient to use 0xa0000000001749e0 since the
correct value changes somewhat.  normally i suspect one would write:

	addl r15=3D@ltoff(@fptr(real_afs_syscall#)),gp

but this would be wrong in this case since when the syscall occurred
i would using the kernel's gp and not the module's gp.  so i thought
i would write:

        .globl afs_syscall_fptr
afs_syscall_fptr:
        data8 0x0
        data8 0x0
GLOBAL_ENTRY(afs_syscall)
        movl r15=AFs_syscall_fptr

and the module could fill in afs_syscall_fptr during init.  when i load
this though i get the following:

insmod: obj_ia64.c:258: obj_ia64_ins_imm64: Assertion `slot =3D 1' failed.

after looking the modutil code i guess that insmod is unable to insert
the relocation for my 64-bit absolute reference?  how should i write this?

