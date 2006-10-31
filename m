From: Jay Lan <jlan@sgi.com>
Date: Tue, 31 Oct 2006 18:08:40 +0000
Subject: Re: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
Message-Id: <45479128.7050100@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546623D.5000105@engr.sgi.com>
In-Reply-To: <4546623D.5000105@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou, Nanhai wrote:

>> We do not rely on machine crash on CPU 0 any more. If the
>> crashing CPU is not cpu 0 and the cpu 0 not being returned to
>> the slave loop, this case is handled by our PROM now.
>>
>> However, if somebody tries to boot up a production kernel using '-le'
>> option _after_ the kexec'ed kernel is up running, the third kernel
>> would not boot unless we boot up the second kernel with cpu 0. I
>> posted a question on "if running 'kexec -le' on a kexec'ed kdump
>> kernel is legal" earlier and Vivek responded saying the scenario
>> is not guranteed to work. So, i think we are fine here.
> 
>   Ok, so with this patch and the PROM fix, on a SN system,
>   1. Kdump -> 2nd kernel works.
>   2. Kdump -> 2nd kernel -> Kexec to third kernel will not work.
>   3. Kexec -> 2nd Kernel -> Kexec -> 3rd kernel works?
>   4. Kexec -> 2nd Kernel -> Kdump -> 3rd kernel works?
> 
>   I think if scenario 1, 3 and 4 works it will be ok. Scenario 2 is not so useful I guess.
> 

The '-l' option caused a seg fault of kexec:

[root@pogo1 boot]# /home/jlan/kexec -l
/boot/efi/efi/redhat/vmlinuz-2.6.18-kdump
--initrd=/boot/efi/efi/redhat/initrd-2.6.18-kdump
--append="root=/dev/sdb6 rhgb irqpoll ro quite"
Done with process_options
kernel: 0x2000000000328010 kernel_size: 3503fec
memory_range: crashk, idx=5, start018000000, end028000000
memory_range: Boot, idx=7, start07a280010, end07a280061
memory_range: MemoryMap, idx=9, start07a3f0010, end07a3f0611
build_mem_shdrs: ei_class=2, e_shnumF, e_shoffT509848
build_mem_shdrs: sizeof(e_shdr)r, e_shdr=0x6000000000014120
ready to load. type=0,
build_mem_shdrs: ei_class=2, e_shnumF, e_shoffT509848
build_mem_shdrs: sizeof(e_shdr)r, e_shdr=0x6000000000014f30
elf_exec_load
Invalid memory segment 0x4000000 - 0x498bfff
Segmentation fault
[root@pogo1 boot]#

It is on my list but my priority is to make sure kdump work (on
sysrq-c, INIT, MCA) and to ensure /proc/vmcore contains correct
and needed information for SN.


Thanks,
 - jay
