From: Luming Yu <luming.yu@gmail.com>
Date: Sun, 04 Jul 2010 09:23:27 +0000
Subject: Re: [RFC PATCH --take 2] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT
Message-Id: <AANLkTikYFO2zp5IvTA7u8ebkw5pCy34wjykHTQW2Ahqo@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AANLkTin0QevX0zZaFc4-LVcoIWfRGmzDKUOSIRKdjKgn@mail.gmail.com>
In-Reply-To: <AANLkTin0QevX0zZaFc4-LVcoIWfRGmzDKUOSIRKdjKgn@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Sun, Jul 4, 2010 at 11:31 AM, Luming Yu <luming.yu@gmail.com> wrote:
> On Tue, Jun 29, 2010 at 2:53 AM, Tony Luck <tony.luck@intel.com> wrote:
>> Patch is incomplete. I'm seeing errors
>>
>> include/linux/irqflags.h:59:26: error: asm/irqflags.h: No such file or d=
irectory
>>
>> because the patch didn't create arch/ia64/include/asm/irqflags.h
>
> Sorry for the inconvenience. Need to git diff HEAD instead of just git di=
ff
> An update patch has been enclosed in =C2=A0attachment of the reply.
>
>>
>>
>> Could you provide a bit more detail on what the issues are that
>> require touching each of the generic files (or at least something
>
> I will provide back trace for each of them later
>
>> on whether these changes are temporary workarounds that should
>> go away later, or real stuff that needs changes)
>>
>> =C2=A0fs/ioctl.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 | =C2=A0 =C2=A01
>
> In the syscall entry path, I've added hardirqs_on trace,
> but still saw lockdep wanning complained for not traced
> hardirq-on event and inconsistent hardware interrupt bit with
> software bit in hardirq trace. It happened to several other system call a=
s well.
>
> All these system call related stuff will be removed in final patch.

Here is a back trace

------------[ cut here ]------------
WARNING: at kernel/lockdep.c:3171 check_flags+0x1c0/0x480()
Hardware name: server rx8640
Modules linked in: autofs4 hidp rfcomm l2cap crc16 bluetooth rfkill
lockd sunrpc cpufreq_ondemand acpi_cpufreq freq_table ipv6 vfat fat
loop dm_multipath scsi_dh power_meter hwmon parport_pc lp parport sg
sr_mod cdrom tpm_tis tpm tpm_bios button tg3 libphy shpchp dm_snapshot
dm_zero dm_mirror dm_region_hash dm_log dm_mod qla2xxx
scsi_transport_fc mptspi mptscsih mptbase scsi_transport_spi sd_mod
scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd

Call Trace:
 [<a000000100016890>] show_stack+0x70/0xc0
                                sp=E000070586357b40 bsp=E000070586351db8
 [<a000000100016930>] dump_stack+0x50/0x80
                                sp=E000070586357d10 bsp=E000070586351d98
 [<a000000100093930>] warn_slowpath_common+0xf0/0x140
                                sp=E000070586357d10 bsp=E000070586351d50
 [<a0000001000939e0>] warn_slowpath_null+0x60/0x80
                                sp=E000070586357d10 bsp=E000070586351d20
 [<a0000001000f42e0>] check_flags+0x1c0/0x480
                                sp=E000070586357d10 bsp=E000070586351cf8
 [<a0000001000fb420>] lockdep_trace_alloc+0x60/0x220
                                sp=E000070586357d10 bsp=E000070586351cc8
 [<a000000100204c50>] kmem_cache_alloc+0x70/0x440
                                sp=E000070586357d10 bsp=E000070586351c80
 [<a000000100234060>] getname+0x60/0x2c0
                                sp=E000070586357d10 bsp=E000070586351c48
 [<a000000100238970>] user_path_at+0x50/0x160
                                sp=E000070586357d10 bsp=E000070586351c08
 [<a000000100223010>] vfs_fstatat+0x90/0x100
                                sp=E000070586357db0 bsp=E000070586351bc0
 [<a0000001002232e0>] vfs_stat+0x60/0x80
                                sp=E000070586357dc0 bsp=E000070586351b90
 [<a000000100223350>] sys_newstat+0x50/0xc0
                                sp=E000070586357dc0 bsp=E000070586351b28
 [<a00000010000b8b0>] ia64_trace_syscall+0xf0/0x130
                                sp=E000070586357e30 bsp=E000070586351b28
 [<a000000000100720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E000070586358000 bsp=E000070586351b28
---[ end trace 15928062f32a2ccf ]---
possible reason: unannotated irqs-on.
irq event stamp: 57606
hardirqs last  enabled at (57605): [<a0000001008ca9a0>]
_raw_spin_unlock_irq+0x80/0xc0
hardirqs last disabled at (57606): [<a000000100017430>]
do_notify_resume_user+0x210/0x280
softirqs last  enabled at (57594): [<a0000001000a4040>] __do_softirq+0x4c0/=
0x4e0
softirqs last disabled at (57579): [<a0000001000a4110>] do_softirq+0xb0/0x1=
60
