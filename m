From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 22 Feb 2000 23:08:54 +0000
Subject: Re: [Linux-ia64] ILP32 support?
Message-Id: <marc-linux-ia64-105590678204957@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204954@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204954@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 22 Feb 2000 14:21:14 -0800, "Vadim Furman" <vadimf@mainsoft.com> said:

  Vadim> Are there any plans to support ILP32 mode?  Vadim Furman

No.  So far, nobody has felt that the (small) benefits of ILP32 are
worth its trouble.  No kernel mods would be required, but you'd have
to create a completely new user-level environment (new compiler, new
header files, all libraries would have to be recompiled with ILP32
mode, etc.).

	--david


