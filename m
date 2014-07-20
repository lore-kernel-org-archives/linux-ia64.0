From: Nick Krause <xerofoify@gmail.com>
Date: Sun, 20 Jul 2014 21:29:04 +0000
Subject: Re: [PATCH] ia64: Fix me add register r8
Message-Id: <CAPDOMVh59+sRfDOLw5VEHXdbaet5B2xv=REJUSUJ+um6jMoe0Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1405661102-11967-1-git-send-email-xerofoify@gmail.com>
	<CAA9xbM4fvo8uKrhJU8Mvp_3HQ=PcrBgq4p_JL0cy_-rX2nL_Bg@mail.gmail.com>
In-Reply-To: <CAA9xbM4fvo8uKrhJU8Mvp_3HQ=PcrBgq4p_JL0cy_-rX2nL_Bg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, Jul 20, 2014 at 4:49 PM, Émeric MASCHINO
<emeric.maschino@gmail.com> wrote:
> Hi,
>
> Well, I'm wondering why the original author of this FIXME comment
> didn't fix the issue him/herself. Can you track down who added this
> comment? I fear that this simple comment was actually here to point to
> something more subtle...
>
>      Émeric
>


 Émeric,
I ran git blame on the file and I got this name,  Shaohua Li
for the fix me and the whole function .

Nick
