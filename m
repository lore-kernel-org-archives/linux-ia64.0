From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 02 Nov 2006 07:45:20 +0000
Subject: RE: [PATCH]IA64 trap code 16 bytes atomic copy on montecito, take 2
Message-Id: <000101c6fe52$d9753b70$bf80030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454961EE.4070608@intel.com>
In-Reply-To: <454961EE.4070608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mao, Bibo wrote on Wednesday, November 01, 2006 7:12 PM
> @@ -463,7 +469,10 @@ void __kprobes arch_arm_kprobe(struct kp
> 
> 	flush_icache_range((unsigned long)p->ainsn.insn,
> 			(unsigned long)p->ainsn.insn + sizeof(kprobe_opcode_t));
> -	memcpy((char *)arm_addr, &p->opcode, sizeof(kprobe_opcode_t));
> +	if (ATOMIC_UPDATE)
> +		kprobe_update_bundle((void *)arm_addr, (void *)&p->opcode);
> +	else
> +		memcpy((char *)arm_addr, &p->opcode, sizeof(kprobe_opcode_t));
> 	flush_icache_range(arm_addr, arm_addr + sizeof(kprobe_opcode_t));
> }

Now comments on the code: why memcpy in the else statement?  In the earlier
part of the patch, you already reject kprobe address on slot 1 if CPU doesn't
have 16-byte memory operation.  Why do you allow memcpy here? Will the "else"
condition ever be executed?
