From: Erich Focht <focht@ess.nec.de>
Date: Mon, 21 May 2001 22:22:13 +0000
Subject: [Linux-ia64] Re: exporting __cpu_physical_id
Message-Id: <marc-linux-ia64-105590693005636@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005634@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005634@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, ia64_cpu_to_sapicid sounds good, too, if it's exported! Thanks for the
warning...

Regards,
Erich

On Mon, 21 May 2001, David Mosberger wrote:

> I assume you're using cpu_physical_id() in your code?  I don't mind
> exporting the physical id array, but Asit sent me an SMP cleanup patch
> which renames __cpu_physical_id to ia64_cpu_to_sapicid, so the actual
> name exported will be different.  As long as your code uses
> cpu_physical_id(), you'll be fine, though.
> 
> 	--david
> 
> >>>>> On Mon, 21 May 2001 17:33:17 +0200 (MEST), Erich Focht <focht@ess.nec.de> said:
> 
>   Erich> Hello, does anything speak against adding the line
> 
>   Erich> EXPORT_SYMBOL(__cpu_physical_id);
> 
>   Erich> somewhere into arch/ia64/kernel/smp.c ?  I'd need to use the
>   Erich> hardware CPU IDs from within a loadable module and I didn't
>   Erich> find any other 'exported' function or array with the needed
>   Erich> information...
> 
>   Erich> Thanks in advance!
> 
>   Erich> Best regards, Erich


