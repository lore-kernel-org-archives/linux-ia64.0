From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 18 Nov 2003 10:11:20 +0000
Subject: [RFC] How drivers notice a MCA on I/O read? [1/3]
Message-Id: <marc-linux-ia64-106915044130197@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all, 

Assuming that Linux uses privilege level to determine action on MCA between
kill the thread and down the system, if driver encounters MCA caused by I/O
read, Linux should be down since privilege level of driver is kernel, not user.
I want to convey the error to the offending driver, and want to enable the
driver to retry failed read.

So, I think about a readb_check function that has checking ability enable
it return error value if MCA occur on read.
Drivers could use readb_check instead of usual readb, and could diagnosis
whether a retry be required or not, by the return value of readb_check.

To realize this, I consider following two plans:

 - readb_check on driver (with Notifier)
    Outline:
    - Platform specific MCA handler has a Notifier as hook point.
    - Driver may register a hook function to the Notifier.
    - Notifier calls over registered functions when MCA is signaled.
    - Called hook function checks address of error, and if the error seems
      to be concerned with the parent driver, ups internal error flag and
      stops Notifier by returning OK.
    - MCA handler regards state of Notifier, and decides the system to
      resume or not.
    - Restarted driver may refer the error flag after read, and may retry
      the read if flag is up.
    Feature:
    - Generic kernel is not changed.
    - Require a platform specific MCA handler.
    - Service is available for platform specific drivers.

 -readb_check on kernel
    Outline:
    - Kernel has readb_check function.
    - Drivers may use readb_check instead of usual readb.
    - MCA handler checks address of error, and if it occurs in readb_check,
      changes return value of readb_check and resumes interrupted context.
    - Driver may refer the return value to notice MCA in last read procedure.
    Feature:
    - Generic kernel requires new codes.
    - Require some codes in generic MCA procedure.
    - Service is available for all drivers.

Which one is better?
IMO, this is a general-purpose function that should be available on many
IA64 platforms (maybe not only IA64), and there is no need to equip
homogenous codes for each platform.
To simplify coding in driver, one on kernel looks good.


Best regards

------

H.Seto <seto.hidetoshi@jp.fujitsu.com>

