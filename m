From: Takanori Kawano <t-kawano@ebina.hitachi.co.jp>
Date: Tue, 04 Jun 2002 07:45:42 +0000
Subject: [Linux-ia64] Question about wbinvd
Message-Id: <marc-linux-ia64-105590701905635@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I have a question about wbinvd in acpi code.

In 2.4.18, wbinvd is implemented in drivers/acpi/include/platform/acgcc.h
 as follows.

static inline void
wbinvd (void)
{
        unsigned long flags, vector, position = 0;
        long status;

        do {
                ia64_clear_ic(flags);
                status = ia64_pal_cache_flush(0x3, (PAL_CACHE_FLUSH_INVALIDATE
                                                    | PAL_CACHE_FLUSH_CHK_INTRS)
,
                                              &position, &vector);
                local_irq_restore(flags);
                if (status = 1) {
                        ia64_eoi();
                        hw_resend_irq(NULL, vector);
                }
        } while (status = 1);
}

I think it may cause infinite loop if PAL_CACHE_FLUSH continues to 
exit for a pending interrupt without flushing any lines. 
Is it correct to call hw_resend_irq as is?

regards,
---
Takanori Kawano
Hitachi Ltd,
Internet Systems Platform Division
t-kawano@ebina.hitachi.co.jp

