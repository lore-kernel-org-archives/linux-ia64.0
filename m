From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Mon, 27 Oct 2003 08:07:19 +0000
Subject: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106724227826901@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I want to make contributions to the development of MCA Error Handling.

According to IPF Error Handling Guide, OS should have capability to recover from
error.

There are three types of error, Corrected, Recoverable, and Fatal. They are
reported to OS by MCA/CPEI/CMCI, and actions required to OS depend on the type
of them. Relations between the type and the action are as follows;

 - Corrected:
     Do nothing.

 - Recoverable:
     Depends on the situation,
     - Fix the error, continue interrupted thread.
     - Terminate suffered threads.
     - Just as Fatal, reboot.

 - Fatal:
     Reboot system immediately.

In all case, Linux should log error information based on SAL record.
So, some programs in user land, like fault prediction logic or
a daemon that reports error to remote site, could use these logs. And
system administrator also could use these logs to keep their system
healthy.


I have strong expectations for Linux to realize such recovery features.
However, Linux is deficient in recovery codes, especially on recoverable MCA,
at this moment. (I know your good job, Tony.)

I want to know what difficulty keep Linux as-is.

What do you think of error recovery on Linux?
What kind of functions, macros, structures should Linux have for recovery?


Best regards,

------

H.Seto <seto.hidetoshi@jp.fujitsu.com>

