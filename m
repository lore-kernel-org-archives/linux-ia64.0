From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Thu, 03 Oct 2002 02:46:40 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.39)
Message-Id: <marc-linux-ia64-105590701906082@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On Sat, 28 Sep 2002 14:48:37 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> The major change in this patch is that I switched the IOSAPIC code
> over to use the ACPI subsystem.  This brings us more in sync with the
> x86 tree and avoids code duplication.  I tested this both on Big Sur
> and zx1 and it seems to work fine.  The integration is not perfect
> yet, because on ia64 linux the irq number is still different from the
> ACPI GSI (for no good reason, IMHO).  Hopefully, someone can take a
> look into changing this.

I'll look into it.

Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


