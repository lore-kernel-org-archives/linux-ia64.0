From: Horms <horms@verge.net.au>
Date: Thu, 26 Jul 2007 02:55:04 +0000
Subject: Re: panic from vector domain patch (was RE: Linus' tree broken?)
Message-Id: <20070726025502.GA15706@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1185239265.19353.6.camel@phobos>
In-Reply-To: <1185239265.19353.6.camel@phobos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 25, 2007 at 11:26:42AM -0400, Doug Chapman wrote:
> On Wed, 2007-07-25 at 22:37 +0900, Horms wrote:
> 
> > I was also seeing a strange problem relating to the
> > vector domain patch which seemed to be causing
> > corruption of vectors_in_migration, which caused migrate_irqs()
> > to emmit suprious IRQ errors (when called by kexec).
> > 
> > I'll try and confirm that this patch soles the problem that
> > I was seeing tomorrow.
> > 
> 
> You may also want to try this patch:
> http://www.mail-archive.com/linux-ia64@vger.kernel.org/msg03113.html

Hi Doug, Hi Ishimatsu-san,

I've tested both of these patches against my problem,
and I notice that they have both been incoporated into
Linus's tree.

It seems that "vector-domain - handle assign_irq_vector(AUTO_ASSIGN)"
(8f5ad1a8227aa110d633b5ed04dde535381c16c7) had no effect on
the problem that I was seeing. But "vector-domain - fix vector_table"
(6ffbc82351c62eeeeaeb9e817ddf93049353493d) appears to resolve the
problem.

As I spent quite a lot of time examining this problem I'll
put my findings below, on the off chance they are of use to
someone in the future.

In my .bss I see that vector_table is right next to
vectors_in_migration, so it seems to make a lot of sense
that inapropriate access to vector_table was corrupting
vectors_in_migration. Furthermore, I added farily large
array, vectors_in_migration_guard between vectors_in_migration and
vector_table and the problem went away, wich seems to futher
pack up the coruption caused by access to vector_table idea.

a000000100587eb8 <vectors_in_migration>:
        ...

a0000001005884b8 <vector_table>:
        ...


I guess that if CPU_HOTPLUG was disabled then some other table
would be corrupted, perhaps one that is accessed much more often
than vectors_in_migration.

For the record, the IRQ errors on kexec
were being caused by fixup_irqs() making inapropriate
calls to generic_handle_irq() due to the corruption of
vectors_in_migration. fixup_irqs() is indirectly called by cpu_down().
The log on a system with NR_CPUS=4 is below:

# do_kexec
Kexec: Linux->Linux
Create ramdisk
19296 /tmp/initramfs_data.cpio
kexec-ia64 -l "/boot/vmlinux-ia64-kexec.gz" \
    --initrd=/tmp/initramfs_data.cpio \
    --append="NAME=rx2620 ip=on loglevel=8  console=tty0 console=uart,mmio,0xff5e0000,115200n8"
Kexec
kexec-ia64 -e
Starting new kernel
ifdown: socket: Function not implemented
irq 318, desc: a00000010050cb00, depth: 1, count: 0, unhandled: 0
->handle_irq():  a000000100437c80, __end_rodata+0x34d8/0x13858
->chip(): a000000100563848, no_irq_chip+0x0/0x80
->action(): 0000000000000000
  IRQ_DISABLED set
Unexpected irq vector 0x13e on CPU 1!
irq 344, desc: a00000010050d800, depth: 1, count: 0, unhandled: 0
->handle_irq():  a000000100437c80, __end_rodata+0x34d8/0x13858
->chip(): a000000100563848, no_irq_chip+0x0/0x80
->action(): 0000000000000000
  IRQ_DISABLED set
Unexpected irq vector 0x158 on CPU 1!
irq 346, desc: a00000010050d900, depth: 1, count: 0, unhandled: 0
->handle_irq():  a000000100437c80, __end_rodata+0x34d8/0x13858
->chip(): a000000100563848, no_irq_chip+0x0/0x80
->action(): 0000000000000000
  IRQ_DISABLED set
Unexpected irq vector 0x15a on CPU 1!
irq 350, desc: a00000010050db00, depth: 1, count: 0, unhandled: 0
->handle_irq():  a000000100437c80, __end_rodata+0x34d8/0x13858
->chip(): a000000100563848, no_irq_chip+0x0/0x80
->action(): 0000000000000000
  IRQ_DISABLED set
Unexpected irq vector 0x15e on CPU 1!
CPU 1 is now offline
Linux version 2.6.23-rc1-kexec-ge4903fb5-dirty (horms@tabatha.lab.ultramonkey.org) (gcc version 3.4.5) #173 SMP Thu Jul 26 11:36:46 JST 2007

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

