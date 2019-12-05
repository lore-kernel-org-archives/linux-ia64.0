From: LABBE Corentin <clabbe@baylibre.com>
Date: Thu, 05 Dec 2019 15:29:45 +0000
Subject: Re: [PATCH v2 0/5] agp: minor fixes, does the maintainer still there ?
Message-Id: <20191205152945.GB10549@Red>
List-Id: <linux-ia64.vger.kernel.org>
References: <1574324085-4338-1-git-send-email-clabbe@baylibre.com>
 <20191202133254.GA21550@Red>
 <CAMwc25obOebugXGSNVWd1bjPN+tR82wwFJ6PgqnvZXK4O6xAFw@mail.gmail.com>
In-Reply-To: <CAMwc25obOebugXGSNVWd1bjPN+tR82wwFJ6PgqnvZXK4O6xAFw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Airlie <airlied@redhat.com>
Cc: airlied <airlied@linux.ie>, arnd@arndb.de, fenghua.yu@intel.com, "KH, Greg" <gregkh@linuxfoundation.org>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Dec 03, 2019 at 06:01:15AM +1000, David Airlie wrote:
> On Mon, Dec 2, 2019 at 11:33 PM LABBE Corentin <clabbe@baylibre.com> wrote:
> >
> > On Thu, Nov 21, 2019 at 08:14:40AM +0000, Corentin Labbe wrote:
> > > Hello
> > >
> > > This patch serie fixes some minor problem found in the agp subsystem
> > > There are no change since v1 (posted two years ago)
> > > This is simply a repost for trying to get an answer (gentle ping 6 month
> > > ago got no answer also).
> > >
> > > Regards
> > >
> >
> > Hello
> >
> > Does the AGP maintainer still maintain it ?
> 
> It's maintained but really loathe to touch it, I've no hw to validate
> any changes on so making any changes to it really has to get past my
> internal, I care enough about this change to risk applying anything to
> AGP.
> 
> I'll try and look and apply those patches today.
> 

Thanks for applying.
Perhaps you need to fix your address in MAINTAINERS.

When you has hardware, What was your tests procedure ?
I can on my freetime add some AGP hw on my kernelCI lab.

Regards
