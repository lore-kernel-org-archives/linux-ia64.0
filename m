From: "bibo,mao" <bibo.mao@intel.com>
Date: Thu, 02 Nov 2006 07:52:39 +0000
Subject: Re: [PATCH]IA64 trap code 16 bytes atomic copy on montecito, take
Message-Id: <4549A3C7.1050305@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454961EE.4070608@intel.com>
In-Reply-To: <454961EE.4070608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:
> Mao, Bibo wrote on Wednesday, November 01, 2006 7:12 PM
>> @@ -463,7 +469,10 @@ void __kprobes arch_arm_kprobe(struct kp
>>
>> 	flush_icache_range((unsigned long)p->ainsn.insn,
>> 			(unsigned long)p->ainsn.insn + sizeof(kprobe_opcode_t));
>> -	memcpy((char *)arm_addr, &p->opcode, sizeof(kprobe_opcode_t));
>> +	if (ATOMIC_UPDATE)
>> +		kprobe_update_bundle((void *)arm_addr, (void *)&p->opcode);
>> +	else
>> +		memcpy((char *)arm_addr, &p->opcode, sizeof(kprobe_opcode_t));
>> 	flush_icache_range(arm_addr, arm_addr + sizeof(kprobe_opcode_t));
>> }
> 
> Now comments on the code: why memcpy in the else statement?  In the earlier
> part of the patch, you already reject kprobe address on slot 1 if CPU doesn't
> have 16-byte memory operation.  Why do you allow memcpy here? Will the "else"
> condition ever be executed?
> 
else means that current cpu does not support 16 byte atomic operation. If kprobe
address is on slot 0/2, then memcpy still can execute.

thanks
bibo,mao 
