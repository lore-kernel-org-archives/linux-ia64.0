From: Francois Wellenreiter <Francois.Wellenreiter@Ext.Bull.Net>
Date: Fri, 07 Jan 2005 14:13:31 +0000
Subject: INIT handler modification
Message-Id: <41DE990B.702@Ext.Bull.Net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


				Dear all,


	first of all, my best wishes for this new year.
Second, I just wanted to start a discussion about INIT handler 
considerations.
Here is the main point, the present code of INIT handler for slave CPUs 
is reduced
to (file arch/ia64/kernel/mca_asm.S) :
______________________________

GLOBAL_ENTRY(ia64_slave_init_handler)
1:      br.sptk 1b
END(ia64_slave_init_handler)
______________________________

I think that when the kernel is deadlocked on another CPU than the 
monarch one,
the traces may be a bit short when I push on the "DUMP" button to have a 
complete
diagnosis of my system.

Thus, I propose you to change the following code (file 
arch/ia64/kernel/mca.c)
______________________________

void __init
ia64_mca_init(void)
{
         ia64_fptr_t *mon_init_ptr = (ia64_fptr_t 
*)ia64_monarch_init_handler;
         ia64_fptr_t *slave_init_ptr = (ia64_fptr_t 
*)ia64_slave_init_handler;
.....
______________________________

into

______________________________

void __init
ia64_mca_init(void)
{
         ia64_fptr_t *mon_init_ptr = (ia64_fptr_t 
*)ia64_monarch_init_handler;
         ia64_fptr_t *slave_init_ptr = (ia64_fptr_t 
*)ia64_monarch_init_handler;
.....
______________________________

What do you think about it ? Do you fear it may induce an unwanted 
behavior towards MCA handling ?

Best regards,

					Francois WELLENREITER

