From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Mon, 24 Jul 2006 16:10:51 +0000
Subject: Re: bogus gas error messages
Message-Id: <ed5aea430607240910j3704545axfc3c6fa3e67c0eb0@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea430607211009l37cad6afj39cf70865a81d3ef@mail.gmail.com>
In-Reply-To: <ed5aea430607211009l37cad6afj39cf70865a81d3ef@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jim,

On 21 Jul 2006 20:34:58 -0700, James E Wilson <wilson@tuliptree.org> wrote:

> There is similar language in the Software Conventions and Run-time
> Architecure Guide.  In Appendix B, Unwind Descriptor Record Format,
> section B.5, in the Format X2 description, it gives encodings for all
> registers other than r0/f0/f1.  Looking at this, it is clear that r0 is
> a problem here, because the obvious encoding for r0 is actually used by
> the restorereg record type.

You're right, the SCRA does exclude spilling of f0/f1 via the X2
descriptor.  I didn't remember that being the case.  I agree that the
asssembler shouldn't emit code that would be undefined per SCRA, so
the current behavior gas is fine.  I'll need to update the libunwind
test-suite to account for that.

Thanks,

  --david
-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
