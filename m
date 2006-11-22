From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 22 Nov 2006 22:01:20 +0000
Subject: Re: How to test system program in hp ski simulator???
Message-Id: <87y7q3m98v.wl%peterc@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <9b33a9230611210517m6160ad87w39be400f47c7873e@mail.gmail.com>
In-Reply-To: <9b33a9230611210517m6160ad87w39be400f47c7873e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "sudhnesh" = sudhnesh adapawar <sudhnesh@gmail.com> writes:

sudhnesh> Hey all !  I am a newbie and have following doubts regarding
sudhnesh> hp ski simulator....  I have ia32 archi and i cross-compiled
sudhnesh> the tools and installed ski properly !  1) Ski does not
sudhnesh> resolve shared library for applications.So do we have to
sudhnesh> statically link each and every ia64 binaries ?  

Use an IA64 chroot, and things *should* work.  Although I've been
seeing problems (illegal operation faults) in bskinc recently.

See http://www.gelato.unsw.edu.au/IA64wiki/SkiSimulator for useful
stuff on Ski.
sudhnesh> 2) Can
sudhnesh> anyone tell me how to test system programs(ia64) in ski
sudhnesh> simulator ?  Useful link related will do !  

Your best bet is to run a complete emulated kernel and root file
system.


--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
Peter 
