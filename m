From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 31 May 2001 04:44:34 +0000
Subject: [Linux-ia64] new version of NUE (IA-64 LDK) available for downloads
Message-Id: <marc-linux-ia64-105590693005676@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,


I wanted to let you know that there is now a new version of the 
HP IA-64 Linux Development Kit (LDK) available for free download at:

	http://www.software.hp.com/LIA64

The LDK allows users to easily (most of the time, no makefile modifications 
required) port/develop Linux/ia64 applications on their Linux/ia32 systems. 
You can compile, RUN and DEBUG the generated binaries using the HP ski IA-64 
simulator included in the kit.

It is also possible to do kernel developments and boot the latest Linux/ia64
kernel using this simulator.

The full environment has been tested on Redhat6.2, 7.0, 7.1 versions and 
should be fine on most other RPM-based distributions. You need about 400MB
of disk space to install the kit. Upgrading from previous versions is supported.

The new version includes:
	- an updated NUE filesystem 

	- the latest gcc-2.x stable version for Linux/ia64

	- glibc version 2.2

	- an updated version of ski (0.943)

	- an updated root filesystem for booting the Linux kernel with the 
	  simulator

You can download the 4 RPMS for free from the web site mentioned above
or have a CDROM sent to you.

Users are encouraged to subscribe to the lia64-sim public mailing-list:

To subscribe:
	- send mail to majordomo@linux.hpl.hp.com
	  with "subscribe lia64-sim" in the body of the message

or participate in the discussion forum at:

	http://devresource.hp.com/devresource/Forums/Forums.html

Enjoy,
-- 
+--------------------------------------------------------------------+
| Ste'phane ERANIAN                       | Email eranian@hpl.hp.com |
| Hewlett-Packard Laboratories            |                          |
| 1501, Page Mill Road MS 1U-15           |                          |
| Palo  Alto, CA 94303-096                |                          |
| USA                                     |                          |
| Tel : (650) 857-7174                    |                          |
| Fax : (650) 857-5548                    |                          |
+--------------------------------------------------------------------+

