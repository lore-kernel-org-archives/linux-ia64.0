From: "Choi, Youngsoo" <youngsoo.choi@intel.com>
Date: Tue, 02 Oct 2001 17:00:30 +0000
Subject: [Linux-ia64] pfmon runs halted a system (2.4.9 kernel)
Message-Id: <marc-linux-ia64-105590698805293@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
We are running RedHat 7.1 Linux on an Itanium BigSur with 2.4.9 kernel.
When we ran some benchmarks with pfmon, the system often halted and needed
rebooting, especially when the running script was executed from rlogin
session. Running from console did not cause the problem as much, but some.
Is there any way to trace where it occurs and what's the reason?
Is pfmon more stable with 2.4.10 kernel without any other issues?

Thank you,

-------
Youngsoo Choi


