From: "Robert K Gjertsen" <gjertsen@us.ibm.com>
Date: Thu, 07 Feb 2002 17:08:36 +0000
Subject: [Linux-ia64] success with remote power mgmt of Lions
Message-Id: <marc-linux-ia64-105590698806016@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Finally figured out how to reboot and power up/down
these Lions remotely on the cheap (can't afford
a remote power switch with 20A sockets).

Basically it involves updating some firmware parameters
for the BMC with a program I snagged from IBM
(and this is probably available from Intel), and
then using the ISC client program I grabbed from Intel
that I'm running on an NT box which allows remote
system power management of the Lion boxes
over a LAN.

 I've tried this on 2 of my Lions at FW 83B w/
BMC 22. I don't believe this will work with an
SDV desktop box though.

The program for toggling BMC parameters from IBM is

  IBM e(logo)server xSeries 380 - Server Management Configuration Utility v
1.01

and at the link:

http://www-1.ibm.com/support/manager.wss?rs=0&rt=1&q=xSeries+380&mr 0&r&cid=2

When running the program at the efi prompt you'll want to
mainly work with the ECP and LAN sections in the program
to set the network settings and activate things for
power management (and make sure to set up passwords).

Right now we are using the latest intel ISC client on an NT box.
I grabbed v 3.5 from the following site under "Software & Drivers"
http://www.intel.com/support/motherboards/server/isc/INDEX.HTM.
I only really use the "DPC Console manager" for power manager
in this program and keep a "phonebook" of the Lion servers.

Usual disclaimer that none of this is supported by IBM or Intel.
I think that should be enough info to get this set up.

It would be nice to get the CD from Intel that would allow setting
up a service partiiton and seeing if I could get remote console
management working (even though this also isn't supported).
Sort of wonder in general why this stuff isn't supported at all when
the hardware/bios capabilities are all in place for this.

--Rob


