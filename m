From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 07 Sep 2005 02:11:08 +0000
Subject: RE: [patch] make exception handler in copy_user more robust
Message-Id: <200509070211.j872Bng21886@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509062306.j86N64g19803@unix-os.sc.intel.com>
In-Reply-To: <200509062306.j86N64g19803@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

david mosberger wrote on Tuesday, September 06, 2005 7:08 PM
> On 9/6/05, Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:
> 
> > Does anyone need precise partial copy_user,
> > meaning copy all the bytes up until faulting address?
> 
> Yes, I'm pretty sure that's the case.  I recall seeing problems with
> mount option copying when copy_user doesn't give the exact number of
> bytes that haven't been copied.

OK, in that case, we won't be able to simplify too much code in the
exception handler.  Good for me :-p

- Ken

