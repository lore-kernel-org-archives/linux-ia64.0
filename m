From: Thomas Hiller <thomas.hiller@sap.com>
Date: Tue, 18 Jul 2000 11:47:06 +0000
Subject: [Linux-ia64] gcc/as problem: integer operand out of range
Message-Id: <marc-linux-ia64-105590678205202@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When I compile a c++ program with gcc I get the following messages:

iaxxsldc.S: Assembler messages:
iaxxsldc.S:4791: Error: Bad operand value: integer operand out of range
iaxxsldc.S:4861: Error: Bad operand value: integer operand out of range
iaxxsldc.S:4879: Error: Bad operand value: integer operand out of range
iaxxsldc.S:8895: Error: Bad operand value: integer operand out of range
iaxxsldc.S:8933: Error: Bad operand value: integer operand out of range

where 4791 reads as follows:
add     r32 = -8808, r32

Is this a gas problem ? A gcc problem ?

Thanks in advance.

Kind regards,
Thomas

--
Thomas Hiller                                           thomas.hiller@compaq.com
COMPAQ Computer Corporation                             thomas.hiller@sap.com
Global SAP Solution Center                              Tel: +49 6227 / 7-45426
LinuxLab @ SAP, Walldorf                                Fax: +49 6227 / 7-43027





