From: Uros Prestor <uros@turbolinux.com>
Date: Sat, 11 Nov 2000 02:26:08 +0000
Subject: Re: [Linux-ia64] SDV Upgrade -- turbolinux install problem?
Message-Id: <marc-linux-ia64-105590678205685@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205684@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205684@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Cole, Ben" wrote:

> Sorry if this is posted to the wrong place -- suggestions for redirect are
> welcomed!

Turbolinux specific questions should go to ia64-dist@turbolinux.com

> Just got my Itanium box upgraded to B1, and am trying to install the 8/28
> Turbolinux
> distribution -- am getting to the "scsi(0): Determining if RISC is
> loaded..." line, where
> it hangs.  Has anyone else seen this?

If it's a Lion system, did you enable >4G addressing for the Qlogic adapter?
The README explains how to do this.

Uros

--
Uros Prestor
uros@turbolinux.com




