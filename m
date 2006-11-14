From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Tue, 14 Nov 2006 01:25:00 +0000
Subject: RE: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086B20@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546623D.5000105@engr.sgi.com>
In-Reply-To: <4546623D.5000105@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Jay Lan [mailto:jlan@sgi.com]
> Sent: 2006=C4=EA11=D4=C211=C8=D5 3:23
> To: Zou, Nanhai
> Cc: fastboot; Linux-IA64; Jack Steiner; Luck, Tony
> Subject: Re: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
>=20
> Zou, Nanhai wrote:
> >>>  But this will rely on machine crash on CPU 0?
> >> We do not rely on machine crash on CPU 0 any more. If the
> >> crashing CPU is not cpu 0 and the cpu 0 not being returned to
> >> the slave loop, this case is handled by our PROM now.
> >>
> >> However, if somebody tries to boot up a production kernel using '-le'
> >> option _after_ the kexec'ed kernel is up running, the third kernel
> >> would not boot unless we boot up the second kernel with cpu 0. I
> >> posted a question on "if running 'kexec -le' on a kexec'ed kdump
> >> kernel is legal" earlier and Vivek responded saying the scenario
> >> is not guranteed to work. So, i think we are fine here.
> >
> >   Ok, so with this patch and the PROM fix, on a SN system,
> >   1. Kdump -> 2nd kernel works.
> >   2. Kdump -> 2nd kernel -> Kexec to third kernel will not work.
> >   3. Kexec -> 2nd Kernel -> Kexec -> 3rd kernel works?
> >   4. Kexec -> 2nd Kernel -> Kdump -> 3rd kernel works?
> >
> >   I think if scenario 1, 3 and 4 works it will be ok. Scenario 2 is not=
 so
> useful I guess.
>=20
> Hi Nanhai,
>=20
> Where do we stand as to this patch's concern? Did you include this yet?
>=20
> As to Scenario 3 and 4, 'kexec -l' failed on "Inivalid memory segment"
> on SN Altix systems, and i have not had time to dig into it. This patch
> is pretty much doing what you suggested "calling ia64_jump_to_sal"
> to send the cpus to slave loop.
>=20
> We can include cpu 0 also by calling fix_b0_for)bsp() to set up b0
> for cpu 0 in ia64_mca_init(), if so desired. What do you think?


  During kdump_cpu_freeze, putting everybody except cpu0 to rendez state lo=
oks like a hack... However fix_b0_for_bsp is another hack....=20
  Since I think the first one looks less hacky, I will include your patch i=
n my kdump patch.=20
 =20
Thanks
Zou Nan hai
 =20
>=20
> Regards,
>  - jay
>=20
>=20
> [root@pogo1 boot]# /home/jlan/kexec-noio -l /boot/vmlinuz-2.6.18-kdump
> --noio -
> -initrd=3D/boot/initrd-2.6.18-kdump --append=3D"root=3D/dev/sdb6 irqpoll =
ro
> console=3Dt
> tySG0"
> Done with process_options
> kernel: 0x2000000000328010 kernel_size: 3502601
> memory_range: crashk, idx=3D5, start018000000, end028000000
> memory_range: Boot, idx=3D7, start07a280010, end07a280061
> memory_range: MemoryMap, idx=3D9, start07a3f0010, end07a3f0611
> build_mem_shdrs: ei_class=3D2, e_shnumF, e_shoffT506776
> build_mem_shdrs: sizeof(e_shdr)r, e_shdr=3D0x6000000000014120
> ready to load. type=3D0,
> build_mem_shdrs: ei_class=3D2, e_shnumF, e_shoffT506776
> build_mem_shdrs: sizeof(e_shdr)r, e_shdr=3D0x6000000000014f30
> elf_exec_load
> Invalid memory segment 0x4000000 - 0x4997fff
> Segmentation fault
> [root@pogo1 boot]#
>=20
> >
