From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 28 Jan 2003 19:14:38 +0000
Subject: RE: [Linux-ia64] [Patch] trivial fix in linker script
Message-Id: <marc-linux-ia64-105590709805757@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805734@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805734@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 24 Jan 2003 12:05:35 -0800, "Siddha, Suresh B" <suresh.b.siddha@intel.com> said:

  Suresh> hi David, I agree. Attached a bigger patch now :)

Well, it's not pretty so I deferred working on it to the last, and
then I got distracted and forgot to do something about it.

Where exactly does the problem come from?  Is it that the Intel linker
will complain when it finds the same symbol with different types?
This kind of overzealous checking is quite a pain and is, IMHO, pretty
much a bug (there are other annoying "features" like that in the Intel
toolchain, for example that the assembler insists on all external
symbols being declared; what a pain...).  If we need to have a
workaround, we can add one but we should clearly document why the ugly
hacks are needed.

	--david

