From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 11 Mar 2003 19:24:44 +0000
Subject: Re: [Linux-ia64] 2.4.20 / DIG
Message-Id: <marc-linux-ia64-105590709806028@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806024@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806024@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Bjorn" = Bjorn Helgaas <bjorn_helgaas@hp.com> writes:

Bjorn> It's not know to me, at least.  Any chance you can use a serial
Bjorn> console to capture the output?  You could also check for MCA log
Bjorn> information -- that's a likely cause of an early reboot.  You
Bjorn> don't say what box you have, but typically you can go to the EFI
Bjorn> shell and use something like "errdump mca".

I'll try hooking up a serial console for it.

The box is an old Intel BigSur beta box that was upgraded with C0 CPUs.

Cheers,
Jes

