From: Matthew Wilcox <willy@debian.org>
Date: Fri, 22 Nov 2002 05:10:06 +0000
Subject: Re: [Linux-ia64] First cut at SMP-safe preemption for IA64
Message-Id: <marc-linux-ia64-105590709805471@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805470@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805470@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Nov 22, 2002 at 03:53:52PM +1100, Peter Chubb wrote:
> @@ -235,14 +234,15 @@
>  
>  	if (!tty || !info->xmit.buf) return;
>  
> -	spin_lock_irqsave(&serial_lock, flags);
> +	local_save_flags(flags);
> +	local_irq_disable();

i think you mean to use local_irq_save(flags) here (and several other cases).

-- 
Revolutions do not require corporate support.

