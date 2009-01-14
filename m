From: Alessandro Zummo <alessandro.zummo@towertech.it>
Date: Wed, 14 Jan 2009 21:39:19 +0000
Subject: Re: [rtc-linux] Re: [PATCH] add rtc platform driver for EFI
Message-Id: <20090114223919.120405f6@i1501.lan.towertech.it>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090109005644.GH32403@ldl.fc.hp.com>
	<20090109032729.6e4cd5fd@i1501.lan.towertech.it>
	<20090109213615.GD31548@ldl.fc.hp.com>
	<20090113003934.0a7da676.akpm@linux-foundation.org>
	<20090114000043.GB24423@colo.lackof.org>
	<20090114011719.GD24423@colo.lackof.org>
	<20090114023055.1d22d09e@i1501.lan.towertech.it>
	<20090114041358.GA21357@ldl.fc.hp.com>
	<20090114043337.GB21357@ldl.fc.hp.com>
	<20090114115728.15f2db18@i1501.lan.towertech.it>
	<20090114173745.GA24492@ldl.fc.hp.com>
	<20090114132554.1efce88f.akpm@linux-foundation.org>
In-Reply-To: <20090114132554.1efce88f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rtc-linux@googlegroups.com
Cc: akpm@linux-foundation.org, dann frazier <dannf@dannf.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, eranian@googlemail.com

On Wed, 14 Jan 2009 13:25:54 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> - the LEAP_YEAR macro is buggy - it references its arg multiple times. 
>   Fix this by turning it into a C function.
> 
> - give it a more approriate name
> 
> - Move it to rtc.h so that other .c files can use it, instead of copying it.

 Seems nice! I'll send to Linus :))))


 Acked-by: Alessandro Zummo <a.zummo@towertech.it>

-- 

 Best regards,

 Alessandro Zummo,
  Tower Technologies - Torino, Italy

  http://www.towertech.it

