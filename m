From: Steven Cole <elenstev@mesatop.com>
Date: Mon, 09 Sep 2002 22:01:21 +0000
Subject: [Linux-ia64] [trivial] Request for merging of two sets of redundant SGI IA64
Message-Id: <marc-linux-ia64-105590701906017@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Greetings,

Could one of you help resolve the following very trivial problem.  In
2.4.20-pre5 Documentation/Configure.help, there exists two
Configure.help entries for CONFIG_IA64_SGI_SN_SIM and
CONFIG_IA64_SGI_SN_DEBUG.

The configurators will of course only display the first of the two.
Would someone please indicate which of the texts is the more accurate or
combine them as you see fit.  You can send me the results or make up a
patch yourself.

If this is a moot point, deleting the second text would be the default
thing to do.

Thanks,
Steven
(Configure.help maintainer)

1st text for CONFIG_IA64_SGI_SN_SIM:

CONFIG_IA64_SGI_SN_SIM
  Build a kernel that runs on both the SGI simulator AND on hardware.
  There is a very slight performance penalty on hardware for including this
  option.

2nd text for CONFIG_IA64_SGI_SN_SIM:

Enable SGI Medusa Simulator Support
CONFIG_IA64_SGI_SN_SIM
  If you are compiling a kernel that will run under SGI's IA64
  simulator (Medusa) then say Y, otherwise say N.

--------------------------------------------------------------------------

1st text for CONFIG_IA64_SGI_SN_DEBUG:

CONFIG_IA64_SGI_SN_DEBUG
  This enables addition debug code that helps isolate
  platform/kernel bugs. There is a small but measurable performance
  degradation when this option is enabled.

2nd text for CONFIG_IA64_SGI_SN_DEBUG:

Enable SGI SN extra debugging code
CONFIG_IA64_SGI_SN_DEBUG
  Turns on extra debugging code in the SGI SN (Scalable NUMA) platform
  for IA64.  Unless you are debugging problems on an SGI SN IA64 box,
  say N.




