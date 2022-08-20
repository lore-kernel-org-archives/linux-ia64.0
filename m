From: Sergei Trofimovich <slyich@gmail.com>
Date: Sat, 20 Aug 2022 18:17:51 +0000
Subject: Re: [PATCH] ia64: fix clock_getre(CLOCK_MONOTONIC) to report ITC frequency
Message-Id: <20220820191751.26b125af@nz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220815054944.4130786-1-slyich@gmail.com>
        <20220817122103.ecbd08bd545385e5bf8e0d72@linux-foundation.org>
In-Reply-To: <20220817122103.ecbd08bd545385e5bf8e0d72@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 17 Aug 2022 12:21:03 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 15 Aug 2022 06:49:44 +0100 Sergei Trofimovich <slyich@gmail.com> wrote:
> 
> > clock_gettime(CLOCK_MONOTONIC, &tp) is very precise on ia64 as it uses
> > ITC (similar to rdtsc on x86). It's not quite a hrtimer as it is a few
> > times slower than 1ns. Usually 2-3ns.
> > 
> > clock_getres(CLOCK_MONOTONIC, &res) never reflected that fact and
> > reported 0.04s precision (1/HZ value).
> > 
> > In https://bugs.gentoo.org/596382 gstreamer's test suite failed loudly
> > when it noticed precision discrepancy.
> > 
> > Before the change:
> > 
> >     clock_getres(CLOCK_MONOTONIC, &res) reported 250Hz precision.
> > 
> > After the change:
> > 
> >     clock_getres(CLOCK_MONOTONIC, &res) reports ITC (400Mhz) precision.
> > 
> > The patch is based on matoro's fix. It adds a bit of explanation why we
> > need to special-case arch-specific clock_getres().
> >   
> 
> It would be best (and nice) to include the original developer's
> Signed-off-by: and to Cc Émeric Maschino if possible?
> 
> Could you please take care of these paperwork issues?

Sounds good!

I'll use matoro's nickname as is for S-o-B the way matoro is comfortable
with to share it. Will add Émeric in v2 and send out in a few minutes.

-- 

  Sergei
