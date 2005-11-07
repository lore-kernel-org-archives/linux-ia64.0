From: Roy Dragseth <Roy.Dragseth@cc.uit.no>
Date: Mon, 07 Nov 2005 10:20:36 +0000
Subject: Re: Probing for physical number of cpus.
Message-Id: <200511071120.37245.Roy.Dragseth@cc.uit.no>
List-Id: <linux-ia64.vger.kernel.org>
References: <200510281318.51532.Roy.Dragseth@cc.uit.no>
In-Reply-To: <200510281318.51532.Roy.Dragseth@cc.uit.no>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thursday 03 November 2005 22:06, Ashok Raj wrote:
> Actually even of you boot with maxcpus=3D1, we still create sysfs entries=
 for
> each cpus physically present in the system.
>
> you should be able to look at /sys/devices/system/cpu/cpuX entries
>
> if you compiled with CONFIG_HOTPLUG_CPU enabled, then you could
> echo 1 > online file in the appropriate cpu directory to add more
> cpus.
>
> Let me know if you dont see this behaviour.

Hi, this is more in line of what I was hoping for ;-)

However I don't see this behaviour on my system.  I'm running RH EL 4 with =

this setup:

[root@testing ~]# ls /sys/devices/system/cpu/
cpu0
[root@testing ~]# uname -a
Linux testing.cluster.none 2.6.9-22.EL #1 SMP Wed Oct 5 15:20:11 EEST 2005 =

ia64 ia64 ia64 GNU/Linux
[root@testing ~]# cat /proc/cmdline
BOOT_IMAGE=3Dscsi0:\EFI\redhat\vmlinuz-2.6.9-22.EL  console=3DttyS0 maxcpus=
=3D1 rhgb=20
quiet root=3DLABEL=3D/1 ro

Upgrading the kernel will not help because I need to be able to probe this =

under the install kernel.

Some background:

This is for the Rocks Cluster Distribution (www.rocksclusters.org), where t=
he=20
compute node installation is done using RH kickstart files that is=20
automatically generated on, and fetched from, the frontend based on the=20
information that is sent from the compute node when it  asks for the=20
kickstart file.  For instance, the number of cpus on the node is used to=20
configure the queueing system.

Any further hints is greatly appreciated.

Regards,
r.

--=20

  The Computer Center, University of Troms=F8, N-9037 TROMS=D8 Norway.
	      phone:+47 77 64 41 07, fax:+47 77 64 41 00
     Roy Dragseth, High Performance Computing System Administrator
	 Direct call: +47 77 64 62 56. email: royd@cc.uit.no
