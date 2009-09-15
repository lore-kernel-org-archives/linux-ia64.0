From: Tony Luck <tony.luck@intel.com>
Date: Tue, 15 Sep 2009 18:39:26 +0000
Subject: Re: [PATCH] cleanup legacy console_print function
Message-Id: <12c511ca0909151139w400256d1t84dad5fa9e1ab3a2@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <DDFD17CC94A9BD49A82147DDF7D545C501F0FF17@exchange.ZeugmaSystems.local>
	 <200909151127.10697.bjorn.helgaas@hp.com>
	 <DDFD17CC94A9BD49A82147DDF7D545C501F100E4@exchange.ZeugmaSystems.local>
	 <12c511ca0909151100ne3841b7l7af5bffb977d6d9b@mail.gmail.com>
	 <DDFD17CC94A9BD49A82147DDF7D545C501F100EB@exchange.ZeugmaSystems.local>
	 <57C9024A16AD2D4C97DC78E552063EA3E05DBC6E@orsmsx505.amr.corp.intel.com>
	 <DDFD17CC94A9BD49A82147DDF7D545C501F10104@exchange.ZeugmaSystems.local>
In-Reply-To: <DDFD17CC94A9BD49A82147DDF7D545C501F10104@exchange.ZeugmaSystems.local>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Anirban Sinha <ASinha@zeugmasystems.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Randy Dunlap <randy.dunlap@oracle.com>, linux-ia64@vger.kernel.org

On Tue, Sep 15, 2009 at 11:25 AM, Anirban Sinha
<ASinha@zeugmasystems.com> wrote:
> =A0arch/ia64/kernel/head.S =A0 =A0| =A0 =A01 -
> =A0arch/ia64/kernel/head.h =A0 =A0| =A0 =A01 -
> =A0arch/ia64/kernel/process.c | =A0 =A02 +-
> =A03 files changed, 1 insertions(+), 3 deletions(-)

The diffstat doesn't match the patch (doesn't include a change to
process.c) ... but the patch itself is OK.

Acked-by: Tony Luck <tony.luck@intel.com>
