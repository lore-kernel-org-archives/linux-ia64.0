From: Tony Luck <tony.luck@intel.com>
Date: Fri, 13 Apr 2012 16:07:01 +0000
Subject: Re: [PATCH] ia64: populate the cmpxchg header with appropriate code
Message-Id: <CA+8MBbKZ7AT-5oMeLqO_n0UEsHfbTjWtDV40Z5gXrm_8RdY-Kw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1333479610-13321-1-git-send-email-paul.gortmaker@windriver.com>
	<CAP=VYLroi_uGBUmwEE2g=nH2z-oD6nYwo_D+o+QHMtWERP=yvA@mail.gmail.com>
	<CA+8MBbJ-Ub9JtJ+nbMScOfcP6HtAjmQ0qZkWOa6H_3A3VHwz7g@mail.gmail.com>
	<CAA9xbM6vKjhy9LH4f=dQqAKRxjQ=3DpP2_QFL0=fJdx+y47JZw@mail.gmail.com>
	<CA+8MBb+LEqcyGQ+qfmnqzmPEtHeOf=XoR4rtpW9Rz74zU80Mkw@mail.gmail.com>
In-Reply-To: <CA+8MBb+LEqcyGQ+qfmnqzmPEtHeOf=XoR4rtpW9Rz74zU80Mkw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, David Howells <dhowells@redhat.com>, Michel Lespinasse <walken@google.com>

On Thu, Apr 12, 2012 at 2:52 PM, Tony Luck <tony.luck@intel.com> wrote:
> IA64 doesn't return a -EFAULT when we poke at the supposedly invalid user
> address of "NULL" because we map a special page to catch prefetch references

Leaping to conclusions ... fail :-(

If I change the address from NULL to something that isn't mapped ... I
still don't
get -EFAULT.

Looking more closely at futex_atomic_cmpxchg_inatomic() for the
error case.

-Tony
