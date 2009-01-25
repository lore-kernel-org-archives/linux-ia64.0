From: Charles Landau <clandau@macslab.com>
Date: Sun, 25 Jan 2009 18:22:46 +0000
Subject: Gateway DX4720-03 apic problem
Message-Id: <497CADF6.10703@macslab.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have a new Gateway DX4720-03 PC and have discovered that it won't 
install Fedora 10 unless I give the kernel boot option "noapic" or 
"nolapic".

This system's processor is the Intel Pentium Dual Core E5200.

It would seem that this is either a kernel bug to be fixed, or a 
documentation bug so users of this machine know about the workaround. 
I'll report the bug if someone will tell me how.
