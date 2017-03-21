From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Tue, 21 Mar 2017 08:33:32 +0000
Subject: Re: GCC 4.9.4-compiled kernel: invalid slot number 1 for IMM64 errors while loading modules
Message-Id: <CAA9xbM5cGgUYhJp1f2i-X8uBd6sHnaXd-jLErOWayV+qRONhjA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

Hi,

For interested people, end of story is [1].

     Émeric

[1] http://marc.info/?l=linux-ia64&m=148994444817965

2017-01-24 15:47 GMT+01:00 Émeric MASCHINO <emeric.maschino@gmail.com>:
> Hi,
>
> Still no thought on this?
>
> I fear this is going to be problematic in the near future, as there's
> currently a discussion about raising the minimum GCC version required
> to build the kernel [1].
>
> In my experience, problems really started with GCC 4.6 and things seem
> to go worse and worse with newer kernel and/or GCC versions (maybe
> implying interactions from peculiar glibc and/or binutils too), as
> reported in [2], [3] and [4] for example.
>
>      Émeric
>
>
> [1] http://lkml.iu.edu/hypermail/linux/kernel/1612.2/00176.html
> [2] https://bugs.gentoo.org/show_bug.cgi?id=518130
> [3] https://bugs.gentoo.org/show_bug.cgi?id=541828
> [4] https://gcc.gnu.org/bugzilla/show_bug.cgi?id=60465
>
> 2016-11-23 21:37 GMT+01:00 Émeric MASCHINO <emeric.maschino@gmail.com>:
>> Hi,
>>
>> GCC 4.9.4 just got stabilized on Gentoo ia64, so I've rebuilt my
>> system packages, including kernel. This yields to a non-booting
>> kernel, with the following errors:
>>
>>>> Loading modules
>>    :: Loading from pata:
>>    :: Loading from sata:
>>    :: Loading from scsi:
>>    :: Loading from usb: usb_storage: invalid slot number 1 for IMM64
>>
>>    :: Loading from firewire:
>>    :: Loading from waitscan:
>>    :: Loading from dmraid:
>>    :: Loading from mdadm: raid0: invalid slot number 1 for IMM64
>> raid1: invalid slot number 1 for IMM64
>> async_tx: invalid slot number 1 for IMM64
>> async_tx: invalid slot number 1 for IMM64
>> async_tx: invalid slot number 1 for IMM64
>> raid10: invalid slot number 1 for IMM64
>>
>>    :: Loading from fs: jbd2: invalid slot number 1 for IMM64
>> jbd2: invalid slot number 1 for IMM64
>> jbd2: invalid slot number 1 for IMM64
>> sunrpc: invalid slot number 1 for IMM64
>> fuse: invalid slot number 1 for IMM64
>>
>>    :: Loading from net: libphy:
>>
>>    :: Loading from iscsi:
>>>> Initializing root device...
>>>> Mounting /dev/sdb3 as root...
>>>> Detected fstype: ext4
>>>> Using mount fstype: ext4
>>>> Using mount opts: -o ro
>> jbd2: invalid slot number 1 for IMM64
>> mount: mounting /dev/sdb3 on /newroot failed: No such device
>> !! Cannot mount /dev/sdb3, trying with -t auto
>> UFS-fs: warning (device sdb3): udf_fill_super: No partition found (2)
>> mount: mounting /dev/sdb3 on /newroot failed: Invalid argument
>> !! Cannot mount /dev/sdb3 with -t auto, giving up
>> !! Could not mount specified ROOT, try again
>> !! Could not find the root block device in /dev/sdb3.
>> !! Please specify another value or:
>> !! - press Enter for the same
>> !! - type "shell" for a shell
>> !! - type "q" to skip...
>> root block device(/dev/sdb3) ::
>>
>> These "invalid slot number 1 for IMM64" messages seem to originate
>> from arch/ia64/kernel/module.c, but I don't know how to deal with
>> them. It's noteworthy that the exact same kernel source built with GCC
>> 4.5.4 or 4.9.3, using the same kernel configuration file, boots fine.
>>
>> Does anybody have success building kernel with recent GCC? Am I seeing
>> a problem with GCC, the kernel or in-between?
>>
>> Thanks,
>>
>>      Émeric
