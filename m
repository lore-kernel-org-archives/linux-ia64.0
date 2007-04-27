From: Christian Kandeler <christian.kandeler@hob.de>
Date: Fri, 27 Apr 2007 15:16:57 +0000
Subject: Inquiry about brl statement
Message-Id: <200704271716.57969.christian.kandeler@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello, 

in the definition of the BRL_COND_FSYS_BUBBLE_DOWN macro in 
arch/ia64/kernel/gate.S, shouldn't there be a stop bit after the brl.cond 
instruction? According to the Intel specs, the current definition (which has 
no stop bit) triggers undefined behavior.


Regards,
Christian Kandeler
