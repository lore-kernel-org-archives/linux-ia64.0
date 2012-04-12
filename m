From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Thu, 12 Apr 2012 00:15:57 +0000
Subject: Re: [PATCH] ia64: populate the cmpxchg header with appropriate code
Message-Id: <CAA9xbM6vKjhy9LH4f=dQqAKRxjQ=3DpP2_QFL0=fJdx+y47JZw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1333479610-13321-1-git-send-email-paul.gortmaker@windriver.com>
	<CAP=VYLroi_uGBUmwEE2g=nH2z-oD6nYwo_D+o+QHMtWERP=yvA@mail.gmail.com>
	<CA+8MBbJ-Ub9JtJ+nbMScOfcP6HtAjmQ0qZkWOa6H_3A3VHwz7g@mail.gmail.com>
In-Reply-To: <CA+8MBbJ-Ub9JtJ+nbMScOfcP6HtAjmQ0qZkWOa6H_3A3VHwz7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Tony Luck <tony.luck@intel.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, David Howells <dhowells@redhat.com>

Hello,

Will this improve anything w.r.t.
https://bugzilla.kernel.org/show_bug.cgi?idB757

     Emeric


Le 12 avril 2012 01:13, Tony Luck <tony.luck@intel.com> a =E9crit :
> On Tue, Apr 10, 2012 at 3:35 PM, Paul Gortmaker
> <paul.gortmaker@windriver.com> wrote:
>> Just wondering if you had a chance to look at this, and
>> whether it was OK and in your queue.
>
> My only concern is whether there are users who just include <asm/intrinsi=
cs.h>
> to get xchg/cmpxchg ... but I guess it should be easy enough for anyone w=
ho
> has breakage in this area to add <asm/cmpxchg.h>
>
>> It has been in linux-next for > 1wk.
>
> Sadly there are few testers for ia64 building linux-next ... so this does=
n't
> mean as much as it does for an x86 patch :-(
>
>>=A0I've got a fix for
>> arch/alpha and I can bundle this along with it in a pull
>> request if you don't have it in your queue already.
>
> I don't have it queued. If you want to handle it, that is fine. Add an
>
> Acked-by: Tony Luck <tony.luck@intel.com>
>
> -Tony
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
