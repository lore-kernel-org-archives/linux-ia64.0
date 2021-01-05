From: Arnd Bergmann <arnd@kernel.org>
Date: Tue, 05 Jan 2021 13:17:41 +0000
Subject: Re: [PATCH] ia64: fix xchg() warning
Message-Id: <CAK8P3a2KhaEZ-ErAXGi0wOr_z2YT-GUV7r5QMhUoV+e+tpc5zw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210104085806.4176886-1-arnd@kernel.org> <ad54481b-15da-e795-0c1a-bd54d3e8ab87@physik.fu-berlin.de>
 <CAK8P3a3zDB5wh-bdg+fq6nvg9gHrESFhhgss4f47VJ1JOvoE1Q@mail.gmail.com> <71274a7cdf7d48bf9c2fda873fa37727@intel.com>
In-Reply-To: <71274a7cdf7d48bf9c2fda873fa37727@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Yu, Fenghua" <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Jan 4, 2021 at 5:00 PM Luck, Tony <tony.luck@intel.com> wrote:
>
> > I have not received any reply from the ia64 maintainers, I assume they were
> > both out of office for Christmas.
>
> I'm back in the office ... but have no working ia64 machines, nor time to look at patches :-(
>
> Should drop me from the MAINTAINTERS file.

If you like, I can apply the patch below and take that through my
asm-generic tree along with the two bug fixes I sent:

diff --git a/MAINTAINERS b/MAINTAINERS
index 0f2e55faaf7f..b74093803154 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8432,11 +8432,8 @@ F: drivers/i3c/
 F: include/linux/i3c/

 IA64 (Itanium) PLATFORM
-M: Tony Luck <tony.luck@intel.com>
-M: Fenghua Yu <fenghua.yu@intel.com>
 L: linux-ia64@vger.kernel.org
-S: Odd Fixes
-T: git git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git
+S: Orphan
 F: Documentation/ia64/
 F: arch/ia64/

Is that what you had in mind? I see that Fenghua Yu has not been
actively involved for a long time. If you are both out, that would
make the port unmaintained, but that may actually help find someone
else to either volunteer as a maintainer or pay someone if they
have a commercial interest.

    Arnd
