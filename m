From: CH Gowri Kumar <gkumar@csa.iisc.ernet.in>
Date: Wed, 30 Jul 2003 10:20:11 +0000
Subject: Re: Conversion between different types on IA-64
Message-Id: <marc-linux-ia64-105955976416569@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105951522415896@msgid-missing>
In-Reply-To: <marc-linux-ia64-105951522415896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Martin,
> In C just a cast ought to do it.
OOPS! I should have asked it as "IA-64 assembly".

> In asm it seems like you can either ST and then LD4/LD2/LD1, or use
> AND or EXTR.
Seems the instructions extr and extr.u would do the work for signed 
and unsigned forms respectively.

Thanks for the help, Martin.

Regards,
Gowri Kumar

