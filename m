From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Mon, 20 Oct 2003 06:19:14 +0000
Subject: MCA Recovery for Enterprise Server
Message-Id: <marc-linux-ia64-106663088408345@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi.

Now I am considering the way to apply Linux to Mission-Critical Enterprise
system on IPF (Itanium Processor Family) Server. Generally, Enterprise Server
requires high-reliability and high-availability, so I recognize following
features as fundamentals:

 - Recovery from device error
 - Recovery from intermittent corrected error (ex. Single-bit ECC error)
 - Structured Error logging

Aims of these are:

 - Keep stable.
 - Quick maintenance by early error detecting/declaring.


These features we working on are realized by functions that recover system
from hardware error, block suffered device by judging from CPU/Memory/Chipset
error severity. An outline is here:

 a) Fault Location and Error Classification
    Detect suffered unit and determine error severity on interrupted timing.

 b) Recovery from device error
    If error is local, disable suffered devices and block operations target to
    them. Else, reboot system immediately.

 c) Error Logging
    Structured error log helps maintenance engineer, remote maintenance system,
    and policed error observer.

 d) Error Prediction (from intermittent corrected error)
    To prevent expected error on sick component, check every corrected error
    and alert user to confirmed. This feature will be realized by daemon in
    user-land.

I am planning to offer a) to c) by the mid of March 2004, and d) by the end of
2005.


However, some of these features seem to depend on the platform implementation.
So I am designing a Platform-MCA (Machine Check Abort) handler for our IPF
machine.

Is there any guideline(s) to implement Platform-MCA handler?
I have found a symbol named PLATFORM_MCA_HANDLERS in /arch/ia64/kernel/mca.c,
but it seems not to work.

Also, if you know any technique for debugging MCA codes, please show me the
smart way.


Thanks.

------

H.Seto <seto.hidetoshi@jp.fujitsu.com>

