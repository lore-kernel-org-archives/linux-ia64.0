From: Thibaut VARENE <T-Bone@parisc-linux.org>
Date: Sun, 26 Sep 2004 16:33:33 +0000
Subject: kernel troubles on rx2600 while running sbuild
Message-Id: <20040926183333.1592f4cd@Tatooine.r3z0>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I've been having some troubles while running 'sbuild' (debian package
autobuilder system) on freshly installed Debian Sarge rx2600 boxes.

First issue:
rx2600 2-way with 4GB RAM, using debian
kernel-image-2.6.8.1-4-mckinley-smp

The box went into a very unstable state while building aptitude (roughly
5 hours after starting sbuild). Several processes went into "D" state and
the logs started to get flooded by the following 3 lines (repeated 435743
times, that is, until i rebooted the system):

Sep 24 02:03:27 gandalf kernel: b_state=0x00000019, b_size@96
Sep 24 02:03:27 gandalf kernel: device blocksize: 4096
Sep 24 02:03:27 gandalf kernel:__find_get_block_slow() failed.
block05635, b_blocknr05632

At that point I could nonetheless login and reboot the system.
I then ran a disk check just in case (including badblocks check) which
shown nothing.

There I thought that SMP might not be a good idea when running sbuild so I
switched to a UP system, with the same configuration (except for the RAM &
nb of CPUs):

Second issue:
rx2600 1-way with 2GB RAM, using debian kernel-image-2.6.8.1-4-mckinley

The system was taken down approx 4h after staring sbuild, unfortunately
the console logs were bloated with stack dumps and got enventually
purged, so i couldn't gather much info, therefore i'm just posting it for
the record. Here is what I could collect:

<6>note: sh[8180] exited with preempt_count 1
Unable to handle kernel NULL pointer dereference (address
0000000000000028)
sh[8180]: Oops 8813272891392 [18]

As a matter of fact, I can't tell whether this was the problem that took
the machine down. The only thing i can tell, is that switching back to 2.4
(kernel-image-2.4.27-1-mckinley) seems to have made this system much more
stable, since it's been running sbuild now for 16h straight without any
problem.

HTH,


Thibaut VARENE
The PA/Linux ESIEE Team
http://www.pateam.org/
