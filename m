From: dann frazier <dannf@dannf.org>
Date: Wed, 14 Jan 2009 17:39:03 +0000
Subject: Re: [PATCH] add rtc platform driver for EFI
Message-Id: <20090114173903.GB24492@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090109005644.GH32403@ldl.fc.hp.com> <20090109032729.6e4cd5fd@i1501.lan.towertech.it> <20090109213615.GD31548@ldl.fc.hp.com> <20090113003934.0a7da676.akpm@linux-foundation.org> <20090114000043.GB24423@colo.lackof.org> <20090114011719.GD24423@colo.lackof.org> <20090114023055.1d22d09e@i1501.lan.towertech.it> <20090114041358.GA21357@ldl.fc.hp.com> <20090114043337.GB21357@ldl.fc.hp.com> <20090114115728.15f2db18@i1501.lan.towertech.it>
In-Reply-To: <20090114115728.15f2db18@i1501.lan.towertech.it>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alessandro Zummo <alessandro.zummo@towertech.it>
Cc: rtc-linux@googlegroups.com, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stephane eranian <eranian@googlemail.com>

On Wed, Jan 14, 2009 at 11:57:28AM +0100, Alessandro Zummo wrote:
> On Tue, 13 Jan 2009 21:33:38 -0700
> dann frazier <dannf@hp.com> wrote:
> 
> > Munge Stephane Eranian's efirtc.c code into an rtc platform driver
> 
>  almost there :) see below

Thanks - another patch sent.

By the way, what do you think about moving the LEAP_YEAR macro in
rtc-lib into rtc.h to avoid the duplicate definition?

-- 
dann frazier

