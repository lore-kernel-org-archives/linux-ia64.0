From: Francois Wellenreiter <Francois.Wellenreiter@bull.net>
Date: Tue, 10 May 2005 15:27:01 +0000
Subject: KDB improvements for IA64
Message-Id: <4280D2C5.3060604@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org




			Dear all,


	I have been working during the last months for improving KDB product
on IA-64 architecture.

The version I propose to you here solves different problems and implements new
features such as :

- breakpoint misfunctioning on SMP machines

	The global KDB entry and exit sequences have been deeply modified.
The flag set has been reduced to the minimum and spinlock usage had increased.

- "ssb" command is now implemented for IA64.
	Step to taken branch  feature did not exist on the SGI KDB version.
It is working by now, using the taken banch bit in the control register.

- timeouts when exiting from KDB will never occur
	I have noticed that after a long time in KDB, some drivers enter
in timeout sequences. Now, the different ITC values are saved when entering KDB
and restored when going out.

I have done many tests on Bull Novascale machines and the results that I obtain
seem to prove that this version is now stable.

That is the reason why I invite you to test it. Do not to hesitate to give me
your feedback and your comments.

However, the modifications I have done only work for IA64 based machines.
Since I have no IA32 machine to modify and test it, I can not do anything
for this architecture, unless you can give me a PC.

The patches can be downloaded at the following address :

	http://www.bullopensource.org/site_kdb/source.html

I plan to add some explanation pages in a few time to describe more precisely 
the modifications I have done in KDB.

Best regards,

			Francois WELLENREITER



