From: Tony Luck <tony.luck@intel.com>
Date: Fri, 01 Oct 2010 20:47:52 +0000
Subject: Re: [PATCH] serial: ioc3_serial: release resources in error return path
Message-Id: <AANLkTinGZEc7V1MH=xyhdKy5=Pg1NRC9xjVEuqBSWNFL@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1285735279-2952-1-git-send-email-rahul.ruikar@gmail.com>
In-Reply-To: <1285735279-2952-1-git-send-email-rahul.ruikar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Rahul Ruikar <rahul.ruikar@gmail.com>
Cc: Pat Gefre <pfg@sgi.com>, Greg Kroah-Hartman <gregkh@suse.de>, Alan Cox <alan@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 28, 2010 at 9:41 PM, Rahul Ruikar <rahul.ruikar@gmail.com> wrot=
e:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out4;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out3;

> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out4;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out3;

you changed *all* uses of out4 to out3, so with this patch I see:

drivers/serial/ioc3_serial.c:2152: warning: label =91out4=92 defined but no=
t used

So I dropped the first hunks, and changed the last one to this:

>   out4:
> + =A0 =A0 =A0 for (cnt =3D 0; cnt < phys_port; cnt++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(ports[cnt]);
> +
> =A0 =A0 =A0 =A0kfree(card_ptr);
> =A0 =A0 =A0 =A0return ret;

Applied with this change.

Thanks

-Tony
