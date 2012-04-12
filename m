From: Tony Luck <tony.luck@intel.com>
Date: Thu, 12 Apr 2012 02:09:21 +0000
Subject: Re: [PATCH] ia64: populate the cmpxchg header with appropriate code
Message-Id: <CA+8MBbKR-iam78WYfPOkmUdSxtFmfzKU9EvSJSr5g46yk0E+2w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1333479610-13321-1-git-send-email-paul.gortmaker@windriver.com>
	<CAP=VYLroi_uGBUmwEE2g=nH2z-oD6nYwo_D+o+QHMtWERP=yvA@mail.gmail.com>
	<CA+8MBbJ-Ub9JtJ+nbMScOfcP6HtAjmQ0qZkWOa6H_3A3VHwz7g@mail.gmail.com>
	<CAA9xbM6vKjhy9LH4f=dQqAKRxjQ=3DpP2_QFL0=fJdx+y47JZw@mail.gmail.com>
In-Reply-To: <CAA9xbM6vKjhy9LH4f=dQqAKRxjQ=3DpP2_QFL0=fJdx+y47JZw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, David Howells <dhowells@redhat.com>

On Wed, Apr 11, 2012 at 5:15 PM, =C9meric Maschino
<emeric.maschino@gmail.com> wrote:
> Will this improve anything w.r.t.
> https://bugzilla.kernel.org/show_bug.cgi?idB757

I'd be amazed if it did ,,, these patches are just moving the same code
from one header file to a new one (<asm/cmpxchg.h>) - so I don't expect
to see any functional changes.

-Tony
