From: Francois Wellenreiter <Francois.Wellenreiter@Ext.Bull.Net>
Date: Mon, 15 Mar 2004 15:16:49 +0000
Subject: Some questions about kernel behavior towards INIT  interrupt.
Message-Id: <4055C8E1.60501@Ext.Bull.Net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org




			Hi all,


	I'd like to submit a problem I met using ITP tool on an SMP Itanium2 
machine with kernel 2.6.4.
I've noticed that SAL called "ia64_monarch_init_handler" function
for EACH processor when generating an INIT interrupt.

In fact, considering the registration done to the SAL, this function may 
be called only once for monarch processor and the function 
"ia64_init_slave_stack" should be called for the others (using the 
rendez-vous mechanism).

Am I wrong ? If I'm right, then had someone already encountered this 
behavior ?
Thanks for help,

				Francois WELLENREITER

