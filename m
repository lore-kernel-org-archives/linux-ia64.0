From: Matthew Wilcox <willy@debian.org>
Date: Wed, 27 Aug 2003 16:54:18 +0000
Subject: Re: kernel update (relative to 2.6.0-test4)
Message-Id: <marc-linux-ia64-106200379415994@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106192276030286@msgid-missing>
In-Reply-To: <marc-linux-ia64-106192276030286@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Aug 27, 2003 at 09:01:54AM -0700, Luck, Tony wrote:
> Last few lines of the build output (building for Tiger):
> 
>   KSYM    .tmp_kallsyms2.S
>   AS      .tmp_kallsyms2.o
>   LD      vmlinux
>   OBJCOPY arch/ia64/hp/sim/boot/vmlinux.bin
> BFD: arch/ia64/hp/sim/boot/vmlinux.bin: warning: allocated section `.data.nosave' not in segment
>   GZIP    arch/ia64/hp/sim/boot/vmlinux.gz
>   LN      vmlinux.gz
>   Kernel: vmlinux.gz is ready
> 
> Is that .../hp/sim/boot/... path right?  I don't have CONFIG_IA64_HP_SIM
> set in my .config.

Yes, that's right.  David and I had a little discussion about that a
couple of days ago.  It's a harmless change.

> Any clues on what the warning from OBJCOPY really means?
> 
> -Tony
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
