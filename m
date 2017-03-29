From: Samuel Ortiz <sameo@linux.intel.com>
Date: Wed, 29 Mar 2017 06:51:04 +0000
Subject: Re: [PATCH v2] nfc: don't be making arch specific unaligned decisions at driver level.
Message-Id: <20170329065104.GB30988@zurbaran.ger.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201701090839.5u37Hdez%fengguang.wu@intel.com>
 <20170109175222.3162-1-paul.gortmaker@windriver.com>
 <CAP=VYLovck5PFD-5C93QahwkGv3ygkWaKjGy90MjNtEodF242Q@mail.gmail.com>
In-Reply-To: <CAP=VYLovck5PFD-5C93QahwkGv3ygkWaKjGy90MjNtEodF242Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kbuild test robot <lkp@intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-wireless@vger.kernel.org

Hi Paul,

On Tue, Mar 28, 2017 at 06:55:26PM -0400, Paul Gortmaker wrote:
> On Mon, Jan 9, 2017 at 12:52 PM, Paul Gortmaker
> <paul.gortmaker@windriver.com> wrote:
> > Currently ia64 fails building allmodconfig with variations of:
> >
> >    In file included from drivers/nfc/nxp-nci/i2c.c:39:0:
> >    ./include/linux/unaligned/access_ok.h:62:29: error: redefinition of ‘put_unaligned_be64’
> >     static __always_inline void put_unaligned_be64(u64 val, void *p)
> 
> Hi Samuel,
> 
> Do you require changes on this commit, or are you happy to queue it as is?
> Looking at the NFC git history it seems like you are the right person to ask.
I will queue it later this week, sorry for the lag.

Cheers,
Samuel.
