From: Erich Focht <focht@ess.nec.de>
Date: Mon, 07 Jan 2002 17:16:41 +0000
Subject: Re: [Linux-ia64] PATCH redirectable IRQs
Message-Id: <marc-linux-ia64-105590698805762@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805756@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805756@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 7 Jan 2002, Andreas Schwab wrote:

[...]
> |> +		if (redir = 1)
> 
> Just a nit: since redir is a boolean value it should be used as such.

You're right.

[...]
> Should this handle buf[0] = 'f'?  You get this when you read the file, so
> someone will probably try to write in the same format.  Unfortunately this
> conflicts with the use of hexadecimal for the cpu number, so
> irq_affinity_read_proc should perhaps not output the 'f' prefix.

Yes, that's why I left it away. And leaving the output of "f" away in
irq_affinity_read_proc() sounds good, too.

I'll resend the patch with some documentation, as suggested by David.

Regards,
Erich



