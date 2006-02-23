From: David Mansfield <david@cobite.com>
Date: Thu, 23 Feb 2006 22:34:21 +0000
Subject: ioctl32 unknown cmd on Opteron system
Message-Id: <1140734061.28066.28.camel@gandalf.cobite.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi folks,

I'm getting the following kernel message when I try to run a RAID
management tool for the megaraid:

ioctl32(megamgr.bin:12688): Unknown cmd fd(3) cmd(c06e6d00){00}
arg(080f3f00) on /dev/megadev0

The tool is binary only, and is clearly a 32bit version.

My system is a 'AMD Opteron(tm) Processor 246' running kernel
2.6.10-1.771_FC2smp.

Am I correct in guessing that some 'stuff' needs to be added to
fs/compat_ioctl.c to get this working?  

If so, how does one tell whether the ioctl needs 32bit <-> 64bit
twiddling to work? 

If anyone has any hints, I might have time to take a look at it.

For example, how would I find out how this ioctl gets handled on a 32bit
(i386) kernel?

David


