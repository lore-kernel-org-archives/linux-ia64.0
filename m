From: Richard Hirst <rhirst@linuxcare.com>
Date: Fri, 10 Aug 2001 08:15:16 +0000
Subject: Re: [Linux-ia64] Installation.
Message-Id: <marc-linux-ia64-105590698805051@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805050@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805050@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 09, 2001 at 05:35:48PM -0700, Gururaj Ananthateerta wrote:
> I have a B180L system, I want to install linux on it. I visited
> parisc-linux
> site. I am confused which ISO image to pick. There are couple of them
> like *serial  and *sti.
> Please anyone explain me which one to pick and wht they mean.

You posted to the ia64 list, not the parisc one, but anyway...

*serial refers to an ISO for use with a serial console, where you would
install and manage the system via a serial cable link to some other system
(e.g. minicom running on a Linux PC).

*sti refers to Standard Text Interface, which means using the keyboard
and monitor interface to the system.

The '32' and '64' in the ISO names refers to 32 and 64 bit CPUs; yours
is 32 bit.

Assuming your system is currently configured for sti console, you
should be able to force it to use serial console simply by unpluging
the keyboard and cycling power.

When we released the 0.9 ISO we had seperate ISOs for serial and sti
installs on 32 bit machines and a further serial ISO for 64 bit machines.
This is referred to as 0.9.0 now.

Next we released a 0.9.1 ISO, but you should ignore that, as it had
various problems.

The latest release is a 0.9.2 ISO, where we have a single ISO that
works for serial and sti installs on 32 bit machines and for serial
installs on 64 bit machines.

We have two versions of 0.9.2, "Network Install ISO", which is a CD
you can install from, but which has just the base packages on it.  Once
you've installed, you'll need to grab other packages from the network.
0.9.2 "CD Install ISO" is the same, but includes various other packages
that we considered useful.  Even if you install this CD you'll
probably want to upgrade from the network anyway.

Now, none of these are perfect.  If you are using a serial console
then either should work fine for you, and you should use the 0.9.2
one as it is more up-to-date.

If you are using an sti console, then I think the 0.9 ISO will work,
although screen redrawing is poor in the installer.  If you use the
0.9.2 ISO with an sti console, you might find that your keyboard is
dead and you are unable to complete the install.  Unplugging and
replugging the keyboard (while the installer is running) may help,
as might trying some other model of keyboard.

The good news is that the keyboard lockup problems are probably
solved, although the code isn't quite ready for committing.  I guess
we will release a new ISO with 2.4.7 kernel and working keyboard sometime
soon, although I am about to go on holiday for two weeks so it probably
wont happen until I'm back.

Finally, I see you are inside HP; I don't know whether the internal
mirrors have 0.9.2 or not, but they are available on
<http://www.parisc-linux.org/release-0.9/index.html>

Richard


