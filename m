From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 14 Nov 2002 15:53:25 +0000
Subject: RE: [Linux-ia64] Re: memcpy failure
Message-Id: <marc-linux-ia64-105590709805429@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805424@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805424@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> >On Thu, Nov 14, 2002 at 10:01:44AM +0100, Christian Cotte-Barrot wrote:
> > But memcpy from memcpy.S is returning a pointer to dest area.
> > That would lead to quasi non-portable code when the return from memcopy
> > is correctly checked depending on which memcopy function is addressed.
> > But BTW, is it meaningful to take into account a return code
> > that is always the same and which value is known in advance ?
> > Does memcpy suppose to failed in some cases ?

> no, memcpy cannot fail (you get a SIGSEGV in userspace or an MCA in
> kernel space).  checking the return value is meaningless.

That's what I feel as well that it is kind of silly to return something that the caller already has. BUt then, I'm not here to judge the specification ;-)

Anyhow, the fix is fairly easy and won't affect the code size as well as the copy throughput, I should have a patch ready shortly to make everyone happy!

- Ken

