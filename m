From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Mon, 01 Apr 2002 14:42:19 +0000
Subject: RE: [Linux-ia64] Basic Advice Needed
Message-Id: <marc-linux-ia64-105590701905351@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905348@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905348@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The stock IA64 Linux kernel supports 64GB memory and 32 processors.

I've been running on a 4xLion with 32GB ram, with a modified 2.4.9 kernel
(basically fix a couple driver bugs and kick the vm in the teeth so it
doesn't kill my machine).  Others here have been running RedHat 7.2-based
kernels and 2.4.16/18 with the IA64 patches.

If you have problems with > 2GB memory it is most likely due to a driver
problem.  The integrated SCSI and network seem to work fine [network only
uses memory < 2GB]; several others I've had to "fix".

If it just runs "slow", then it is probably a VM issue.

Kevin

