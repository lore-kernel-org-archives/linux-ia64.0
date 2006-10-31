From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Oct 2006 07:53:50 +0000
Subject: RE: [PATCH] IA64 trap code 16 bytes atomic copy on montecito
Message-Id: <000101c6fcc1$b47cc000$5181030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546E55E.3050207@intel.com>
In-Reply-To: <4546E55E.3050207@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

bibo,mao wrote on Monday, October 30, 2006 9:56 PM
>   On IA64 kprobe can not insert trap code on slot 1 because
> opcode of slot 1 crosses over two consecutive 8-bytes. On
> montecito machine 16 bytes atomic operation is avaiable,
> This patch implements 16 bytes atomic copy on montecito
> machine, so that kprobe can probe any slot on montecito
> machine.
> 
> +/* this function uses st16/ld16 to atomically copy one bundle
> + * to code area, it requires src address and dest address is
> + * not in UC/UCE/WC area. Currently kernel physical memory
> + * identified map is cachable and WB, so there is no such check.
> + *  input0: represents whether this cpu supports atomic
> + *	    st16/ld16 instruction
> + *  input1: destionation address of bundle copy
> + *  input2: source address of bundle copy
> + *  return: -1 failed, 0 succeed  
> + */
> +GLOBAL_ENTRY(kprobe_update_inst_bundle)

Hmm, the description doesn't match with implementation.  I'm really
confused to the purpose of this asm function.  It is using a pair of
ld8/st8 or using ld16/st16 depends on cpu feature.  It returns error
only on address mis-alignment. There is no atomicity in there as
claimed in the description.


> @@ -460,10 +465,12 @@ void __kprobes arch_arm_kprobe(struct kp
>  {
>  	unsigned long addr = (unsigned long)p->addr;
>  	unsigned long arm_addr = addr & ~0xFULL;
> +	int atomic;
>  
> +	atomic = local_cpu_data->features & ITANIUM_CPUID4_AO;
>  	flush_icache_range((unsigned long)p->ainsn.insn,
>  			(unsigned long)p->ainsn.insn + sizeof(kprobe_opcode_t));
> -	memcpy((char *)arm_addr, &p->opcode, sizeof(kprobe_opcode_t));
> +	kprobe_update_inst_bundle(atomic, (void *)arm_addr, (void *)&p->opcode);
>  	flush_icache_range(arm_addr, arm_addr + sizeof(kprobe_opcode_t));
>  }

Return value of kprobe_update_inst_bundle() is not used here.  I suggest
re-design the function prototype. What does it mean to have an error? If
it is non-fatal, then why bother return a value?


 
> @@ -471,10 +478,11 @@ void __kprobes arch_disarm_kprobe(struct
>  {
>  	unsigned long addr = (unsigned long)p->addr;
>  	unsigned long arm_addr = addr & ~0xFULL;
> +	int atomic;
>  
> +	atomic = local_cpu_data->features & ITANIUM_CPUID4_AO;
>  	/* p->ainsn.insn contains the original unaltered kprobe_opcode_t */
> -	memcpy((char *) arm_addr, (char *) p->ainsn.insn,
> -					 sizeof(kprobe_opcode_t));
> +	kprobe_update_inst_bundle(atomic, (void *)arm_addr, (void *) p->ainsn.insn);
>  	flush_icache_range(arm_addr, arm_addr + sizeof(kprobe_opcode_t));
>  }
 
Same here with kprobe_update_inst_bundle().
