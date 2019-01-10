From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 10 Jan 2019 22:43:32 +0000
Subject: Re: [PATCH 00/15] arch: synchronize syscall tables in preparation for y2038
Message-Id: <CAK8P3a07yNiadLCJcA0Tyfo90YeQ0P2XF-wOEy9XAb8cDTFObw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190110162435.309262-1-arnd@arndb.de> <CAMuHMdXYP3=TRHYqddVRfbRRaj_Ou=wfoX6ohKM7XNAx-c2RXw@mail.gmail.com>
 <CAK8P3a0kmr2ju+sZE+f-+=-2t5Eu+t-DS-+r6OKrPVTAxHwf8w@mail.gmail.com> <CAMuHMdVpUNUx-wdDYChYNzMYqYi79w5tzjk5x3JskdS88VQCQw@mail.gmail.com>
In-Reply-To: <CAMuHMdVpUNUx-wdDYChYNzMYqYi79w5tzjk5x3JskdS88VQCQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: y2038 Mailman List <y2038@lists.linaro.org>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Andy Lutomirski <luto@kernel.org>, Thomas

On Thu, Jan 10, 2019 at 7:11 PM Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> On Thu, Jan 10, 2019 at 6:06 PM Arnd Bergmann <arnd@arndb.de> wrote:
> > On Thu, Jan 10, 2019 at 5:59 PM Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> > > On Thu, Jan 10, 2019 at 5:26 PM Arnd Bergmann <arnd@arndb.de> wrote:
> > > > The system call tables have diverged a bit over the years, and a number
> > > > of the recent additions never made it into all architectures, for one
> > > > reason or another.
> > > >
> > > > This is an attempt to clean it up as far as we can without breaking
> > > > compatibility, doing a number of steps:
> > >
> > > Thanks a lot!
> > >
> > > > - Add system calls that have not yet been integrated into all
> > > >   architectures but that we definitely want there.
> > >
> > > It looks like you missed wiring up io_pgetevents() on m68k.
> > > Is that intentional?
> >
> > Yes, I thought I had described that somewhere but maybe I
> > forgot: semtimedop() and io_pgetevents() get replaced with
> > time64 versions in the follow-up, so I only added them in
> > 64-bit architectures. If you think we should have both
> > io_pgetevents() and io_pgetevents_time32() on all 32-bit
> > architectures, I can add that as well.
>
> Thanks, sounds fine to me.

Just to be sure, you mean it's fine to not add it, not that we should
add it?

     Arnd
