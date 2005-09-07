From: david mosberger <dmosberger@gmail.com>
Date: Wed, 07 Sep 2005 02:07:37 +0000
Subject: Re: [patch] make exception handler in copy_user more robust
Message-Id: <ed5aea43050906190786bb99c@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509062306.j86N64g19803@unix-os.sc.intel.com>
In-Reply-To: <200509062306.j86N64g19803@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 9/6/05, Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:

> Does anyone need precise partial copy_user,
> meaning copy all the bytes up until faulting address?

Yes, I'm pretty sure that's the case.  I recall seeing problems with
mount option copying when copy_user doesn't give the exact number of
bytes that haven't been copied.

  --david

-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
