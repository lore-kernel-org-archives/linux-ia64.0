From: Francois Wellenreiter <Francois.Wellenreiter@Ext.Bull.Net>
Date: Tue, 30 Mar 2004 07:02:24 +0000
Subject: Abnormal behaviour towards "INIT" interrupt management
Message-Id: <40691B80.9070309@Ext.Bull.Net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


			Hi,

	I've already sent this mail, but receiving no feedback, I try again 
(sorry for people who don't feel concerned by that stuff).
I'd like to report what I estimate a potential bug in the INIT 
management (at the present time I don't know exactly what the origin of 
this problem is).

Testing the "dump" button on a 4-way Itanium-2 machine equipped with a 
SAL 3.0, I've noticed a not-inline with SAL specifications behaviour.
Indeed, in the "ia64_mca_init" function (in arch/ia64/kernel/mca.c file)
we register the functions "ia64_monarch_init_handler" and 
"ia64_slave_init_handler".

Then I push on the "dump" button that generates an INIT interruption to 
all the processors. This signal is then caught by PAL, and SAL which 
calls (with a reason [register GR11] equal to 2) 
"ia64_monarch_init_handler" on the monarch processor and 
"ia64_slave_init_handler" on the slave ones (to this point, I hope to be 
right, isn't it ?).
What I've noticed using traces (and further an ITP tool) is that for 
each processor the "ia64_monarch_init_handler" is ever called. :-(
Could someone tell me if he already has encountered this problem or if 
it is an expected behavior ?

For information, I've done the same test with a 16-way Itanium-2 machine
with a SAL 3.1 and the result is exactly the same.

Thanks for your help.

Best regards,

			Francois WELLENREITER

