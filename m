From: Alex Williamson <alex_williamson@hp.com>
Date: Mon, 04 Aug 2003 18:49:24 +0000
Subject: Re: [PATCH] New CMC/CPE polling
Message-Id: <marc-linux-ia64-106002299006986@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105969308328993@msgid-missing>
In-Reply-To: <marc-linux-ia64-105969308328993@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" wrote:
> 
> I think that there are some race conditions around the setting/clearing
> of cmc_polling_enabled.
> 

Tony,

   You might be right on the clearing side, I think moving it down
a couple lines and disabling local interrupts would eliminate the
potential hole though.  Something like this:

ia64_mca_cmc_int_caller(...)
{
...
    smp_call_function(ia64_mca_cmc_vector_enable, NULL, 1, 0);
    local_irq_disable();
    ia64_mca_cmc_vector_enable(NULL);
    cmc_polling_enabled = 0;
...

   Does that address the race you were looking at?  I don't see one
on the setting end, could you be more specific?  The spinlock feels
like it does the trick to me.  Thanks for the comments,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab
