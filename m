From: Julia Lawall <julia@diku.dk>
Date: Sun, 30 May 2010 05:56:43 +0000
Subject: question about arch/ia64/kernel/iosapic.c
Message-Id: <Pine.LNX.4.64.1005300754160.12022@ask.diku.dk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have the impression that ioremap should not be called with locks held.  
Is this the case?  If so, what should be done in the following code (from 
the function iosapic_init):

        spin_lock_irqsave(&iosapic_lock, flags);
        index = find_iosapic(gsi_base);
        if (index >= 0) {
                spin_unlock_irqrestore(&iosapic_lock, flags);
                return -EBUSY;
        }

        addr = ioremap(phys_addr, 0);
        if (addr = NULL) {
                spin_unlock_irqrestore(&iosapic_lock, flags);
                return -ENOMEM;
        }

thanks,
julia
