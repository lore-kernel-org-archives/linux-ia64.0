From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Thu, 22 May 2014 16:17:13 +0000
Subject: Stable DRI/DRM 3D hardware acceleration on Linux/ia64 (zx1)? The solution: timer frequency
Message-Id: <CAA9xbM6PA3_xM963Ep4KRWJS7KhFVg-nN_OFuGp_RgmyQH1qeQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

[Summary]

For years (as old as 2006), 3D hardware acceleration on ia64 has been
plagued with breakages and stability issues. I found a 2010 post of
mine [1] summarizing all these problems, ranging from the libpci
rewrite, to the switch from UMS to KMS or the switch from Mesa Classic
to Gallium3D driver architecture. In the end, results were always the
same: when DRI is working, my hp workstation zx6000 with its ATI
FireGL X1 AGP graphics adapter and r300g driver randomly freezes
within seconds or minutes, as soon as a serious OpenGL application
(i.e. not glxinfo or glxgears) is run.

[Full story]

Completely unrelated, I eventually stumble upon this 2002 post talking
about timer frequency on i386 (don't ask me how I ended up there, I
don't even remember what I was looking for). There, I found
interesting thoughts, e.g. that ia64 was rumored to use a 1024 HZ
timer frequency [3] whereas Linus pretended that it was in fact 1000
HZ, leading to a reportedly dramatic overhead in CPU cycles due to
increased cache misses that were worrying Intel people at the time
[4]. The alleged overhead in CPU cycles using 1000 HZ timer frequency
was ultimately proven wrong by David Mosberger [5].

Then, selectable timer interrupt frequency came into the kernel, in
May 2005 for ia64 [6]. Looking at the patch there, it's noteworthy
that the HZ variable definition has been changed from 1024 (so, Linus
was wrong) to CONFIG_HZ. By curiosity, I've checked my kernel
configuration: 250 HZ. This is the value selected by default on ia64
with an empty/non-existent .config file. It's noteworthy that this
value is inherited from generic (read non-ia64) kernel configuration
file, as it's not overriden in any of the ia64 default kernel
configuration file (that will lead to another interesting question
that I'll ask separately in this list: who's maintening these default
kernel configuration files and thus ensure their accuracy with today's
kernel code?). Anyway, parsing the timer frequency documentation, I
thought that the right option for me for desktop use would be 1000 HZ
rather than the inherited 250 HZ (plus the fact that ia64 was using
1000 HZ timer frequency in the past, before the inclusion of the
selectable timer frequency).

Upon reboot, the first thing that I immediately noticed was a much
faster boot time. Now that I remember, there was indeed a regression
in boot time during the 2.6 kernel era, but I never care about this
more than this. Retrospectively, I bet that this regression coincides
with the change of the HZ variable value from 1024 to CONFIG_HZ (so
250 HZ for what matters). Days and weeks passed and today I asked
myself: "Hey, this is quite some time now that you didn't experience
stability issues with your OpenGL apps. What's going on"? Looking for
what could have changed on my system explaining this, I nearly
accidentally remembered that I'm now running a kernel with 1000 HZ
timer frequency. Could this be the key? As a triple-check, I've
recompiled my kernel with 100 HZ, 250 HZ and 1000 HZ timer frequency.
Here are the results:
- 100 HZ: OpenGL apps lock the system (machine checks) within seconds;
- 250 HZ: OpenGL apps freeze the system (no machine check but huge CPU
activity making the system barely usable) within minutes;
- 1000 HZ: OpenGL apps rock-stable for several weeks now. Bingo!

[Conclusion]

I don't know how do you all run your kernels today, but all prebuilt
ia64 kernels from Fedora, Debian, openSUSE are configured with 250 HZ
timer frequency, explaining the stability issues during all these
years. In my personal case, this also explains why I've never had
stability issues with the proprietary ATI fglrx driver: this driver
was in use during the 2.4-early 2.6 kernels, so before the selectable
timer interrupt frequency was introduced into the kernel and hence
with the HZ variable set to 1024.

[Epilog]

What do you mean about all this story? From the dmesg logs with the
above tested timer frequencies, there can be performance penalties in
some aspects:
- 100 HZ: ~89 secs. boot time, ia64 xor function: 3113.600 MB/sec,
raid6 int64x16 algorithm: 2969 MB/s;
- 250 HZ: ~53 secs. boot time, ia64 xor function: 3116.000 MB/sec,
raid6 int64x16 algorithm: 2965 MB/s;
- 1000 HZ: ~35 sec. boot time, ia64 xor function: 3104.000 MB/sec,
raid6 int64x16 algorithm: 2941 MB/s.

But if I had to chose between stability and performance, I'll chose
stability. BTW, while increasing timer frequency to 1000 HZ might
affect performances in some ways, it definitely makes system more
responsive. So, at least for zx1-based systems, I greatly encourage
people to select 1000 HZ timer frequency and make it the default
choice in zx1_defconfig file.

     =C3=89meric


[1] http://marc.info/?l=3Ddri-devel&m=126494456828755&w=3D2
[2] http://marc.info/?l=3Dlinux-kernel&m=101894484713495&w=3D4
[3] http://marc.info/?l=3Dlinux-kernel&m=101895197818781&w=3D4
[4] http://marc.info/?l=3Dlinux-kernel&m=101897461907954&w=3D4
[5] http://marc.info/?l=3Dlinux-kernel&m=101900471105628&w=3D4
[6] http://marc.info/?l=3Dlinux-ia64&m=111643909323936&w=3D2
