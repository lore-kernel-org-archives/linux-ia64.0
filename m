From: Keith Owens <kaos@sgi.com>
Date: Sat, 06 Dec 2003 04:16:09 +0000
Subject: Deadlock in ia64_mca_cmc_int_caller
Message-Id: <marc-linux-ia64-107068420607204@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64_mca_cmc_int_caller() calls smp_call_function() which waits until
all cpus have taken the IPI before returning.  This interacts badly
with locks that are sometimes taken with interrupts disabled and
sometimes with interrupts enabled, smp_call_function can deadlock.

cpu 3                                                   cpu 0
Holds tasklist_lock with interrupts enabled,
it did read_lock() or write_lock().

                                                Does read_lock_irq() or
                                                write_lock_irq().  Spinning
                                                disabled waiting for tasklist_lock.

CMC interrupt occurs

ia64_mca_cmc_int_caller() calls smp_call_function()

smp_call_function() sends IPI to other cpus

                                                IPI on cpu 0 blocked, it is disabled
						waiting for tasklist_lock.

smp_call_function() waits until IPI reaches
all other cpus.

cpu 0 never responds, we never release the
tasklist lock, deadlock.

AFAICT it is never safe to call smp_call_function() from an interrupt
handler.

The unsafe nature of smp_call_function is not ia64 specific.  ix86 can
deadlock this way if any ix86 code calls smp_call_function from an
interrupt handler.

